// login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    try {
      setState(() => loading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      // ❌ NO navegar manualmente, AuthGate lo detecta

    } on FirebaseAuthException catch (e) {
      String mensaje = "";
      if (e.code == 'user-not-found') {
        mensaje = "Usuario no encontrado";
      } else if (e.code == 'wrong-password') {
        mensaje = "Contraseña incorrecta";
      } else {
        mensaje = e.message ?? "Error desconocido";
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $mensaje")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _pass,
              decoration: InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            loading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: login,
                        child: Text("Entrar"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text("Crear cuenta"),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
