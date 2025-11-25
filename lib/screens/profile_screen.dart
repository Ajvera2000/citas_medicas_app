import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool loading = true;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    nameController.text = doc["name"] ?? "";
    emailController.text = doc["email"] ?? "";
    setState(() => loading = false);
  }

  Future<void> pickImage() async {
    final p = ImagePicker();
    final picked = await p.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = File(picked.path));
  }

  Future<String?> _uploadImage() async {
    if (imageFile == null) return null;
    final ref = FirebaseStorage.instance.ref().child("profiles/$uid.jpg");
    await ref.putFile(imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> saveChanges() async {
    setState(() => loading = true);
    final url = await _uploadImage();

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      if (url != null) "photoUrl": url,
    });

    if (emailController.text.trim() != FirebaseAuth.instance.currentUser!.email) {
      await FirebaseAuth.instance.currentUser!.updateEmail(emailController.text.trim());
    }

    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Perfil actualizado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return Scaffold(
        appBar: AppBar(title: Text("Mi Perfil")),
        body: Center(child: CircularProgressIndicator()),
      );

    return Scaffold(
      appBar: AppBar(title: Text("Mi Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    imageFile != null ? FileImage(imageFile!) : null,
                child: imageFile == null
                    ? Icon(Icons.camera_alt, size: 40, color: AppColors.primary)
                    : null,
              ),
            ),
            SizedBox(height: 25),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Correo"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              ),
              child: Text("Guardar cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
