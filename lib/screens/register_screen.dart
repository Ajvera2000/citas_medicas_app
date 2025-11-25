// register_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();

  File? imageFile;
  bool loading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        imageFile = File(img.path);
      });
    }
  }

  Future<String?> uploadImage(String uid) async {
    if (imageFile == null) return null;

    final ref = FirebaseStorage.instance.ref("profiles/$uid.jpg");
    await ref.putFile(imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> register() async {
    try {
      setState(() => loading = true);

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(), password: _pass.text.trim());

      String uid = cred.user!.uid;
      final photoUrl = await uploadImage(uid);

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": _name.text.trim(),
        "email": _email.text.trim(),
        "photoUrl": photoUrl,
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cuenta creada correctamente")));

      Navigator.pop(context);
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
      appBar: AppBar(title: Text("Crear cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      imageFile != null ? FileImage(imageFile!) : null,
                  child: imageFile == null ? Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
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
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: register,
                    child: Text("Registrarme"),
                  ),
          ],
        ),
      ),
    );
  }
}
