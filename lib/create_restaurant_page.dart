import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateRestaurantPage extends StatefulWidget {
  const CreateRestaurantPage({super.key});

  @override
  State<CreateRestaurantPage> createState() => _CreateRestaurantPageState();
}

class _CreateRestaurantPageState extends State<CreateRestaurantPage> {
  final _nameController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Restaurant')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Restaurant Name'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createRestaurant,
                    child: const Text('Create Restaurant'),
                  ),
            const SizedBox(height: 20),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Future<void> _createRestaurant() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _message = 'User not logged in!';
        _loading = false;
      });
      return;
    }

    if (!user.emailVerified) {
      setState(() {
        _message = 'Please verify your email before creating a restaurant.';
        _loading = false;
      });
      return;
    }

    try {
      final restaurantRef = _firestore.collection('restaurants').doc();

      final now = DateTime.now();
      final trialEnds = now.add(const Duration(days: 14));

      await restaurantRef.set({
        'name': _nameController.text.trim(),
        'email': user.email,
        'createdAt': now,
        'trialEndsAt': trialEnds,
      });

      // Link restaurant to user
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': 'restaurantAdmin',
        'restaurantId': restaurantRef.id,
      });

      setState(() {
        _message = 'Restaurant created successfully! Trial ends on ${trialEnds.toLocal()}';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to create restaurant: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
