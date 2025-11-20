import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  AppointmentCard({required this.appointment, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd HH:mm');
    return Card(
      child: ListTile(
        title: Text(appointment.patientName),
        subtitle: Text('${appointment.doctorName} • ${df.format(appointment.date)}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'delete') onDelete();
            if (v == 'open') onTap();
          },
          itemBuilder: (_) => [PopupMenuItem(value: 'open', child: Text('Abrir')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))],
        ),
        onTap: onTap,
      ),
    );
  }
}
