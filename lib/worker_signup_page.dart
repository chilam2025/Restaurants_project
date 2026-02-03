import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerSignupPage extends StatefulWidget {
  final String restaurantId; // Admin passes this
  const WorkerSignupPage({super.key, required this.restaurantId});

  @override
  State<WorkerSignupPage> createState() => _WorkerSignupPageState();
}

class _WorkerSignupPageState extends State<WorkerSignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String _message = '';

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Worker')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
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
                    onPressed: _addWorker,
                    child: const Text('Add Worker'),
                  ),
            const SizedBox(height: 20),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Future<void> _addWorker() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      // Create worker account in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Add to Firestore
      await _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('workers')
          .doc(uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'worker',
        'active': true,
      });

      await _firestore.collection('users').doc(uid).set({
        'email': _emailController.text.trim(),
        'role': 'worker',
        'restaurantId': widget.restaurantId,
      });

      // Optionally, send password reset email so worker sets their own password
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      setState(() {
        _message = 'Worker added successfully. They will receive an email to set their password.';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to add worker: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
