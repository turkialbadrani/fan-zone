
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addPoints(int amount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPoints = snapshot.exists ? snapshot.get('points') ?? 0 : 0;
      transaction.set(userRef, {'points': currentPoints + amount}, SetOptions(merge: true));
    });
  }

  Future<int> getPoints() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data()!;
      return data['points'] ?? 0;
    }
    return 0;
  }
}
