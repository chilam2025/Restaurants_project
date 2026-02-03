import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_dashboard/create_restaurant_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Signup')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                  ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _signup() async {
  setState(() {
    _loading = true;
    _message = '';
  });

  try {
    print('Attempting signup...');
    print(_emailController.text.trim());

    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    print('User created: ${userCredential.user?.uid}');

    await userCredential.user!.sendEmailVerification();

    setState(() {
      _message = 'Signup successful! Check your email.';
    });

  } on FirebaseAuthException catch (e) {
    print('FirebaseAuthException: ${e.code}');
    print(e.message);
    setState(() {
      _message = e.message ?? e.code;
    });
  } catch (e) {
    print('Unknown error: $e');
    setState(() {
      _message = e.toString();
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }

  }
}
