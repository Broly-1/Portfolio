import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:hassankamran/models/project.dart';
import 'package:hassankamran/models/home_content.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  static const String _aboutCollection = 'about';
  static const String _projectsCollection = 'projects';
  static const String _homeContentCollection = 'homeContent';

  // Get About data
  Future<Map<String, dynamic>?> getAboutData() async {
    try {
      print('🔍 Fetching about data from Firestore...');
      final doc = await _firestore
          .collection(_aboutCollection)
          .doc('main')
          .get();

      print('📄 Document exists: ${doc.exists}');
      if (doc.exists) {
        final data = doc.data();
        print('✅ Data retrieved: $data');
        return data;
      }
      print('⚠️ No document found');
      return null;
    } catch (e) {
      print('❌ Error getting about data: $e');
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
      print('❌ Error getting resume URL: $e');
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
      print('❌ Error incrementing view count: $e');
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
      print('❌ Error getting view count: $e');
      return 0;
    }
  }

  // ==================== PROJECT METHODS ====================

  // Get all projects
  Future<List<Project>> getProjects() async {
    try {
      print('🔍 Fetching projects from Firestore...');
      final snapshot = await _firestore
          .collection(_projectsCollection)
          .orderBy('order')
          .get();

      print('📄 Found ${snapshot.docs.length} projects');
      return snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
    } catch (e) {
      print('❌ Error getting projects: $e');
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
    try {
      print('🔍 Fetching project $projectId...');
      final doc = await _firestore
          .collection(_projectsCollection)
          .doc(projectId)
          .get();

      if (doc.exists) {
        return Project.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting project: $e');
      return null;
    }
  }

  // Create new project
  Future<String?> createProject(Project project) async {
    try {
      print('➕ Creating new project...');
      final docRef = await _firestore
          .collection(_projectsCollection)
          .add(project.toMap());

      print('✅ Project created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating project: $e');
      return null;
    }
  }

  // Update existing project
  Future<bool> updateProject(String projectId, Project project) async {
    try {
      print('📝 Updating project $projectId...');
      await _firestore
          .collection(_projectsCollection)
          .doc(projectId)
          .update(project.toMap());

      print('✅ Project updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating project: $e');
      return false;
    }
  }

  // Delete project
  Future<bool> deleteProject(String projectId) async {
    try {
      print('🗑️ Deleting project $projectId...');

      // First get the project to delete its thumbnail if exists
      final project = await getProject(projectId);
      if (project?.thumbnailUrl != null) {
        await deleteThumbnail(project!.thumbnailUrl!);
      }

      // Then delete the document
      await _firestore.collection(_projectsCollection).doc(projectId).delete();

      print('✅ Project deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting project: $e');
      return false;
    }
  }

  // Upload project thumbnail
  Future<String?> uploadThumbnail(File file, String projectId) async {
    try {
      print('📤 Uploading thumbnail for project $projectId...');

      final ref = _storage.ref().child('projects/$projectId/thumbnail.png');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('✅ Thumbnail uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading thumbnail: $e');
      return null;
    }
  }

  // Delete thumbnail from storage
  Future<bool> deleteThumbnail(String imageUrl) async {
    try {
      print('🗑️ Deleting thumbnail...');
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Thumbnail deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting thumbnail: $e');
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
      print('🔍 Fetching home content...');
      final doc = await _firestore
          .collection(_homeContentCollection)
          .doc('main')
          .get();

      if (doc.exists) {
        return HomeContent.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting home content: $e');
      return null;
    }
  }

  // Update home content
  Future<bool> updateHomeContent(HomeContent content) async {
    try {
      print('📝 Updating home content...');
      await _firestore
          .collection(_homeContentCollection)
          .doc('main')
          .set(content.toFirestore());

      print('✅ Home content updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating home content: $e');
      return false;
    }
  }
}
