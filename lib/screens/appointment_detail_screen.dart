import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import 'appointment_form_screen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;
  AppointmentDetailScreen({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle'),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentFormScreen(appointment: appointment)))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Paciente: ${appointment.patientName}', style: TextStyle(fontSize: 18)),
          SizedBox(height:8),
          Text('Doctor: ${appointment.doctorName}', style: TextStyle(fontSize: 16)),
          SizedBox(height:8),
          Text('Fecha: ${df.format(appointment.date)}', style: TextStyle(fontSize: 16)),
          SizedBox(height:8),
          Text('Estado: ${appointment.status}', style: TextStyle(fontSize: 16)),
          SizedBox(height:12),
          Text('Notas:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height:6),
          Text(appointment.notes.isNotEmpty ? appointment.notes : 'Sin notas'),
        ]),
      ),
    );
  }
}
