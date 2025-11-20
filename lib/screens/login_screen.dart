import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  final auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      setState(() => loading = true);
      await auth.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _register() async {
    try {
      setState(() => loading = true);
      await auth.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cuenta creada')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _email, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _pass, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 20),
            if (loading) CircularProgressIndicator(),
            if (!loading) Column(
              children: [
                ElevatedButton(onPressed: _login, child: const Text('Entrar')),
                TextButton(onPressed: _register, child: const Text('Crear cuenta')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
