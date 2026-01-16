import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static const String _aboutCollection = 'about';
  static const String adminEmail = 'hassangaming111@gmail.com';

  // Check if current user is admin
  bool isAdmin() {
    final user = _auth.currentUser;
    return user != null &&
        user.email?.toLowerCase() == adminEmail.toLowerCase();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get About data
  Future<Map<String, dynamic>?> getAboutData() async {
    try {
      final doc = await _firestore
          .collection(_aboutCollection)
          .doc('main')
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Save About data
  Future<void> saveAboutData(Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_aboutCollection)
          .doc('main')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String folder) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('$folder/$fileName');

      // Upload file
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Don't rethrow - image might not exist
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
}
