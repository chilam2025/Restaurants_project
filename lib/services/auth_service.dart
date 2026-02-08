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
    print('REGISTER: creating auth user');

    final userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('REGISTER: auth success');

    final data = {
      'email': email,
      'role': role,
      'createdAt': Timestamp.now(),
    };

    if (role == 'worker' && restaurantId != null) {
      data['restaurantId'] = restaurantId;
    }

    print('REGISTER: writing to firestore');

    await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .set(data);

    print('REGISTER: firestore write success');

    return role;
  } catch (e) {
    print('REGISTER ERROR: $e');
    return e.toString();
  }
}

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
