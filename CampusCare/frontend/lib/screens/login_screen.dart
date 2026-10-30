import 'package:flutter/material.dart';
import '../api.dart';
import '../main.dart';
import 'admin_home.dart';
import 'student_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _studentId = TextEditingController();
  bool _registering = false;
  bool _busy = false;

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      if (_registering) {
        await Api.register(_username.text.trim(), _password.text,
            _name.text.trim(), _studentId.text.trim());
      } else {
        await Api.login(_username.text.trim(), _password.text);
      }
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  Session.isAdmin ? const AdminHome() : const StudentHome()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.health_and_safety, size: 56, color: green),
                  const Text('Campus Care',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 16),
                  if (_registering) ...[
                    TextField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Full name')),
                    TextField(
                        controller: _studentId,
                        decoration: const InputDecoration(labelText: 'Student ID')),
                  ],
                  TextField(
                      controller: _username,
                      decoration: const InputDecoration(labelText: 'Username')),
                  TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Text(_registering ? 'Create account' : 'Log in'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _registering = !_registering),
                    child: Text(_registering
                        ? 'I already have an account'
                        : 'New student? Register'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
