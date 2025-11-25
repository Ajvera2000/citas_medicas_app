// home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';
import '../models/appointment.dart';
import '../widgets/appointment_card.dart';
import '../routes.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fs = FirestoreService();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String doctorFilter = '';
  String statusFilter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Citas médicas')),

      // ░░ MENU LATERAL ░░
      drawer: Drawer(
        child: ListView(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return UserAccountsDrawerHeader(
                    accountName: Text("Cargando..."),
                    accountEmail: Text(""),
                  );
                }

                final data = snap.data!;
                final userData = data.data() as Map<String, dynamic>?;

                // Crear documento básico si no existe
                if (userData == null) {
                  FirebaseFirestore.instance.collection("users").doc(uid).set({
                    "name": "Usuario",
                    "email": FirebaseAuth.instance.currentUser!.email ?? "",
                    "photoUrl": null,
                    "createdAt": Timestamp.now(),
                  });
                }

                return UserAccountsDrawerHeader(
                  accountName: Text(userData?["name"] ?? "Usuario"),
                  accountEmail: Text(userData?["email"] ?? FirebaseAuth.instance.currentUser!.email ?? ""),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: userData?["photoUrl"] != null
                        ? NetworkImage(userData!["photoUrl"])
                        : null,
                    child: userData?["photoUrl"] == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text("Mi Perfil"),
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Cerrar sesión"),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: fs.streamAppointmentsForUser(uid),
              builder: (context, snap) {
                if (!snap.hasData)
                  return Center(child: CircularProgressIndicator());

                var lista = snap.data!;
                if (doctorFilter.isNotEmpty)
                  lista = lista.where((a) => a.doctorName == doctorFilter).toList();
                if (statusFilter.isNotEmpty)
                  lista = lista.where((a) => a.status == statusFilter).toList();

                if (lista.isEmpty) return Center(child: Text('No hay citas'));

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final a = lista[i];
                    return AppointmentCard(
                      appointment: a,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.detail, arguments: a),
                      onDelete: () async {
                        await fs.deleteAppointment(a.id!);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.form),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: 'Filtrar por doctor'),
              onChanged: (v) => setState(() => doctorFilter = v.trim()),
            ),
          ),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: statusFilter.isEmpty ? null : statusFilter,
            hint: Text("Estado"),
            items: ['pendiente', 'confirmada', 'cancelada']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => statusFilter = v ?? ''),
          )
        ],
      ),
    );
  }
}
