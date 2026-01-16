import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:hassankamran/models/project.dart';
import 'package:hassankamran/models/home_content.dart';
import 'package:hassankamran/models/app_stats.dart';
import 'cache_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CacheService _cache = CacheService();

  // Collection references
  static const String _aboutCollection = 'about';
  static const String _projectsCollection = 'projects';
  static const String _homeContentCollection = 'homeContent';
  static const String _appStatsCollection = 'appStats';
  static const String _configCollection = 'config';

  // Get GitHub Token
  Future<String?> getGitHubToken() async {
    const cacheKey = 'github_token';

    // Check cache first
    if (_cache.has(cacheKey)) {
      return _cache.get(cacheKey);
    }

    try {
      final doc = await _firestore
          .collection(_configCollection)
          .doc('github')
          .get();

      if (doc.exists && doc.data() != null) {
        final token = doc.data()!['token'] as String?;
        if (token != null) {
          _cache.set(cacheKey, token, duration: const Duration(hours: 24));
        }
        return token;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get About data
  Future<Map<String, dynamic>?> getAboutData() async {
    try {
      final doc = await _firestore
          .collection(_aboutCollection)
          .doc('main')
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Stream About data (real-time updates)
  Stream<Map<String, dynamic>?> streamAboutData() {
    return _firestore
        .collection(_aboutCollection)
        .doc('main')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // Get Resume URL
  Future<String?> getResumeUrl() async {
    try {
      final doc = await _firestore.collection('resume').doc('main').get();
      if (doc.exists) {
        return doc.data()?['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Analytics methods
  Future<void> incrementViewCount() async {
    try {
      final analyticsRef = _firestore.collection('analytics').doc('views');
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(analyticsRef);
        if (snapshot.exists) {
          final currentCount = snapshot.data()?['count'] ?? 0;
          transaction.update(analyticsRef, {'count': currentCount + 1});
        } else {
          transaction.set(analyticsRef, {'count': 1});
        }
      });
    } catch (e) {
      // Error incrementing view count
    }
  }

  Future<int> getViewCount() async {
    try {
      final doc = await _firestore.collection('analytics').doc('views').get();
      if (doc.exists) {
        return doc.data()?['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== PROJECT METHODS ====================

  // Get all projects
  Future<List<Project>> getProjects() async {
    // Check cache first
    final cached = _cache.get<List<Project>>('projects');
    if (cached != null) {
      return cached;
    }

    try {
      final snapshot = await _firestore
          .collection(_projectsCollection)
          .orderBy('order')
          .get(const GetOptions(source: Source.serverAndCache));

      final projects = snapshot.docs
          .map((doc) => Project.fromFirestore(doc))
          .toList();

      // Cache the results
      _cache.set('projects', projects, duration: const Duration(minutes: 15));

      return projects;
    } catch (e) {
      return [];
    }
  }

  // Stream all projects (real-time updates)
  Stream<List<Project>> streamProjects() {
    return _firestore
        .collection(_projectsCollection)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList(),
        );
  }

  // Get single project by ID
  Future<Project?> getProject(String projectId) async {
    // Check cache first
    final cacheKey = 'project_$projectId';
    final cached = _cache.get<Project>(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      final doc = await _firestore
          .collection(_projectsCollection)
          .doc(projectId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (doc.exists) {
        final project = Project.fromFirestore(doc);
        _cache.set(cacheKey, project, duration: const Duration(minutes: 15));
        return project;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create new project
  Future<String?> createProject(Project project) async {
    try {
      final docRef = await _firestore
          .collection(_projectsCollection)
          .add(project.toMap());

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Update existing project
  Future<bool> updateProject(String projectId, Project project) async {
    try {
      await _firestore
          .collection(_projectsCollection)
          .doc(projectId)
          .update(project.toMap());

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete project
  Future<bool> deleteProject(String projectId) async {
    try {
      // First get the project to delete its thumbnail if exists
      final project = await getProject(projectId);
      if (project?.thumbnailUrl != null) {
        await deleteThumbnail(project!.thumbnailUrl!);
      }

      // Then delete the document
      await _firestore.collection(_projectsCollection).doc(projectId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Upload project thumbnail
  Future<String?> uploadThumbnail(File file, String projectId) async {
    try {
      final ref = _storage.ref().child('projects/$projectId/thumbnail.png');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // Delete thumbnail from storage
  Future<bool> deleteThumbnail(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== Home Content Methods ==========

  // Stream home content (real-time updates)
  Stream<HomeContent?> streamHomeContent() {
    return _firestore
        .collection(_homeContentCollection)
        .doc('main')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return HomeContent.fromFirestore(doc.data()!, doc.id);
          }
          return null;
        });
  }

  // Get home content
  Future<HomeContent?> getHomeContent() async {
    try {
      final doc = await _firestore
          .collection(_homeContentCollection)
          .doc('main')
          .get();

      if (doc.exists) {
        return HomeContent.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update home content
  Future<bool> updateHomeContent(HomeContent content) async {
    try {
      await _firestore
          .collection(_homeContentCollection)
          .doc('main')
          .set(content.toFirestore());

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get App Stats
  Future<AppStats?> getAppStats() async {
    const cacheKey = 'app_stats';

    // Check cache first
    if (_cache.has(cacheKey)) {
      return _cache.get(cacheKey);
    }

    try {
      final doc = await _firestore
          .collection(_appStatsCollection)
          .doc('main')
          .get();

      if (doc.exists && doc.data() != null) {
        final stats = AppStats.fromFirestore(doc.data()!, doc.id);
        _cache.set(cacheKey, stats, duration: const Duration(minutes: 15));
        return stats;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update App Stats
  Future<bool> updateAppStats(int iosDownloads, int androidDownloads) async {
    try {
      final stats = AppStats(
        id: 'main',
        iosDownloads: iosDownloads,
        androidDownloads: androidDownloads,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection(_appStatsCollection)
          .doc('main')
          .set(stats.toFirestore());

      // Clear cache
      _cache.clear();

      return true;
    } catch (e) {
      return false;
    }
  }
}
