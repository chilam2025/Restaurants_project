import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _restaurantIdController = TextEditingController();

  final AuthService _authService = AuthService();

  String _role = 'owner';
  bool _loading = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    if (_role == 'worker' &&
        _restaurantIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant ID is required')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _role,
      restaurantId:
          _role == 'worker' ? _restaurantIdController.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result == 'owner' || result == 'worker') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully registered')),
      );

      Navigator.pop(context); // back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? 'Registration failed')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _restaurantIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 15),

              DropdownButton<String>(
                value: _role,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'owner',
                    child: Text('Restaurant Owner'),
                  ),
                  DropdownMenuItem(
                    value: 'worker',
                    child: Text('Worker'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _role = value!);
                },
              ),

              if (_role == 'worker') ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _restaurantIdController,
                  decoration:
                      const InputDecoration(labelText: 'Restaurant ID'),
                ),
              ],

              const SizedBox(height: 25),

              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
