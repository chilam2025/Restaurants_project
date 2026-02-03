import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerLoginPage extends StatefulWidget {
  const WorkerLoginPage({super.key});

  @override
  State<WorkerLoginPage> createState() => _WorkerLoginPageState();
}

class _WorkerLoginPageState extends State<WorkerLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Login')),
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
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        setState(() {
          _message = 'User record not found.';
        });
        return;
      }

      final data = doc.data()!;
      final role = data['role'];
      final restaurantId = data['restaurantId'];

      // Navigate based on role
      if (role == 'restaurantAdmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WorkerSignupPage(restaurantId: restaurantId)),
        );
      } else if (role == 'worker') {
        // Navigate to worker dashboard (implement later)
        setState(() {
          _message = 'Login successful. Worker dashboard coming soon.';
        });
      } else {
        setState(() {
          _message = 'Unknown role.';
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
