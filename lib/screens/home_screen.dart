import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/appointment.dart';
import 'appointment_form_screen.dart';
import 'appointment_detail_screen.dart';
import '../widgets/appointment_card.dart';
import 'calendar_screen.dart';

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
        title: Text('Citas médicas'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () async {
              final citas = await fs.getAppointmentsForUserOnce(uid);
              Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarScreen(citas: citas)));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: fs.streamAppointmentsForUser(uid),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                var lista = snap.data!;
                if (doctorFilter.isNotEmpty) lista = lista.where((a) => a.doctorName == doctorFilter).toList();
                if (statusFilter.isNotEmpty) lista = lista.where((a) => a.status == statusFilter).toList();
                if (lista.isEmpty) return Center(child: Text('No hay citas'));
                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final a = lista[i];
                    return AppointmentCard(
                      appointment: a,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentDetailScreen(appointment: a))),
                      onDelete: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Eliminar'),
                            content: Text('Eliminar cita de ${a.patientName}?'),
                            actions: [
                              TextButton(onPressed: ()=>Navigator.pop(context,false), child: Text('No')),
                              TextButton(onPressed: ()=>Navigator.pop(context,true), child: Text('Sí')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await fs.deleteAppointment(a.id!);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cita eliminada')));
                        }
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentFormScreen())),
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
              decoration: InputDecoration(labelText: 'Filtrar por doctor (exacto)'),
              onChanged: (v) => setState(() => doctorFilter = v.trim()),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: statusFilter.isEmpty ? null : statusFilter,
            hint: Text('Estado'),
            items: ['','pendiente','confirmada','cancelada'].map((s) => DropdownMenuItem(value: s, child: Text(s.isEmpty ? 'Todos' : s))).toList(),
            onChanged: (v) => setState(() => statusFilter = v ?? ''),
          )
        ],
      ),
    );
  }
}
