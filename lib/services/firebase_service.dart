import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static const String _aboutCollection = 'about';

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
}
