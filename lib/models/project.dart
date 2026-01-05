import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String? androidLink;
  final String? iosLink;
  final String? apkLink;
  final String? githubLink;
  final String? thumbnailUrl;
  final String content; // Rich text content
  final DateTime createdAt;
  final DateTime updatedAt;
  final int order; // For sorting projects
  final List<String> tags; // Project tags/technologies

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.androidLink,
    this.iosLink,
    this.apkLink,
    this.githubLink,
    this.thumbnailUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.order = 0,
    this.tags = const [],
  });

  // Convert Project to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'androidLink': androidLink,
      'iosLink': iosLink,
      'apkLink': apkLink,
      'githubLink': githubLink,
      'thumbnailUrl': thumbnailUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'order': order,
      'tags': tags,
    };
  }

  // Create Project from Firestore document
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      androidLink: data['androidLink'],
      iosLink: data['iosLink'],
      apkLink: data['apkLink'],
      githubLink: data['githubLink'],
      thumbnailUrl: data['thumbnailUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      order: data['order'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // Copy with method for easy updates
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? androidLink,
    String? iosLink,
    String? apkLink,
    String? githubLink,
    String? thumbnailUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? order,
    List<String>? tags,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      androidLink: androidLink ?? this.androidLink,
      iosLink: iosLink ?? this.iosLink,
      apkLink: apkLink ?? this.apkLink,
      githubLink: githubLink ?? this.githubLink,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
      tags: tags ?? this.tags,
    );
  }
}
