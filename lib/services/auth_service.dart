import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 LOGIN
  Future<String?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return 'User data not found';
      }

      return userDoc['role']; // owner | worker
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Login failed';
    }
  }

  // 📝 REGISTER
  Future<String?> register({
    required String email,
    required String password,
    required String role,
    String? restaurantId,
  }) async {
    try {
      final userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final data = {
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      };

      if (role == 'worker' && restaurantId != null) {
        data['restaurantId'] = restaurantId;
      }

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(data);

      return role;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Registration failed';
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
