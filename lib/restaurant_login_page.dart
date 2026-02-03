import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'worker_signup_page.dart'; // Admin adds workers
// import 'worker_dashboard_page.dart'; // Workers dashboard page

class RestaurantLoginPage extends StatefulWidget {
  const RestaurantLoginPage({super.key});

  @override
  State<RestaurantLoginPage> createState() => _RestaurantLoginPageState();
}

class _RestaurantLoginPageState extends State<RestaurantLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
            const SizedBox(height: 20),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      // Step 1: Login with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user!;

      // Step 2: Check if email is verified
      if (!user.emailVerified) {
        setState(() {
          _message = 'Please verify your email before logging in.';
        });
        await user.sendEmailVerification(); // optional: resend verification email
        return;
      }

      // Step 3: Fetch user document from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        setState(() {
          _message = 'User record not found. Contact support.';
        });
        return;
      }

      final data = doc.data()!;
      final role = data['role'] ?? '';
      final restaurantId = data['restaurantId'] ?? '';

      // Step 4: Route based on role
      if (role == 'restaurantAdmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => WorkerSignupPage(restaurantId: restaurantId)),
        );
      } else if (role == 'worker') {
        // TODO: Implement Worker Dashboard Page
        setState(() {
          _message =
              'Login successful. Worker dashboard will be implemented next.';
        });
      } else {
        setState(() {
          _message = 'Unknown role. Contact support.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message ?? 'Login failed.';
      });
    } catch (e) {
      setState(() {
        _message = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
