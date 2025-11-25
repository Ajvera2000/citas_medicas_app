import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';
import '../models/appointment.dart';
import '../widgets/appointment_card.dart';
import '../routes.dart';
import '../theme.dart';

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
      appBar: AppBar(
        title: Text('Citas Médicas'),
        backgroundColor: AppColors.primary,
      ),
      drawer: _buildDrawer(),
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
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.detail,
                        arguments: a,
                      ),
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
        backgroundColor: AppColors.secondary,
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.form),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
            builder: (_, snap) {
              if (!snap.hasData) {
                return UserAccountsDrawerHeader(
                  accountName: Text("Cargando..."),
                  accountEmail: Text(""),
                  decoration: BoxDecoration(color: AppColors.primary),
                );
              }

              final data = snap.data!.data() as Map<String, dynamic>?;

              return UserAccountsDrawerHeader(
                accountName: Text(data?["name"] ?? "Usuario"),
                accountEmail: Text(
                    data?["email"] ?? FirebaseAuth.instance.currentUser!.email ?? ""),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: data?["photoUrl"] != null
                      ? NetworkImage(data!["photoUrl"])
                      : null,
                  child: data?["photoUrl"] == null
                      ? Icon(Icons.person, size: 50)
                      : null,
                ),
                decoration: BoxDecoration(color: AppColors.primary),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: AppColors.primary),
            title: Text("Mi Perfil"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.primary),
            title: Text("Cerrar sesión"),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
        ],
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
              decoration: InputDecoration(
                labelText: 'Filtrar por doctor',
                prefixIcon: Icon(Icons.search, color: AppColors.secondary),
              ),
              onChanged: (v) => setState(() => doctorFilter = v.trim()),
            ),
          ),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: statusFilter.isEmpty ? null : statusFilter,
            hint: Text("Estado"),
            items: ['pendiente', 'confirmada', 'cancelada']
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
            onChanged: (v) => setState(() => statusFilter = v ?? ''),
          )
        ],
      ),
    );
  }
}
