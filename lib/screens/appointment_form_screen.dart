import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AppointmentFormScreen extends StatefulWidget {
  final Appointment? appointment;
  AppointmentFormScreen({this.appointment});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDate;
  String _status = 'pendiente';
  final fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      final a = widget.appointment!;
      _patientCtrl.text = a.patientName;
      _doctorCtrl.text = a.doctorName;
      _notesCtrl.text = a.notes;
      _selectedDate = a.date;
      _status = a.status;
    } else {
      _selectedDate = DateTime.now().add(Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    _doctorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365*2)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now())
    );
    if (time == null) return;
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    final user = FirebaseAuth.instance.currentUser!;
    final a = Appointment(
      id: widget.appointment?.id,
      patientName: _patientCtrl.text.trim(),
      doctorName: _doctorCtrl.text.trim(),
      date: _selectedDate!,
      notes: _notesCtrl.text.trim(),
      status: _status,
      userId: user.uid,
    );

    // Validar conflicto
    final conflict = await fs.doctorHasConflict(a.doctorName, a.date, excludingId: a.id);
    if (conflict) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conflicto: ese doctor ya tiene otra cita a esa hora')));
      return;
    }

    try {
      if (a.id == null) {
        await fs.addAppointment(a);
        // schedule notification
        final notif = Provider.of<NotificationService>(context, listen: false);
        final id = a.date.millisecondsSinceEpoch ~/ 1000;
        await notif.scheduleAppointmentNotification(id, 'Cita médica', 'Cita con ${a.doctorName} (${a.patientName})', a.date);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cita creada')));
      } else {
        await fs.updateAppointment(a);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cita actualizada')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text(widget.appointment == null ? 'Nueva cita' : 'Editar cita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _patientCtrl, decoration: InputDecoration(labelText: 'Nombre paciente'), validator: (v)=>v==null||v.trim().isEmpty ? 'Requerido' : null),
              SizedBox(height: 12),
              TextFormField(controller: _doctorCtrl, decoration: InputDecoration(labelText: 'Nombre doctor'), validator: (v)=>v==null||v.trim().isEmpty ? 'Requerido' : null),
              SizedBox(height: 12),
              ListTile(
                title: Text('Fecha y hora'),
                subtitle: Text(_selectedDate != null ? df.format(_selectedDate!) : 'No seleccionada'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['pendiente','confirmada','cancelada'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v)=>setState(()=>_status=v ?? 'pendiente'),
                decoration: InputDecoration(labelText: 'Estado'),
              ),
              SizedBox(height: 12),
              TextFormField(controller: _notesCtrl, decoration: InputDecoration(labelText: 'Notas'), maxLines: 3),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: Text(widget.appointment==null ? 'Crear' : 'Actualizar')),
            ],
          ),
        ),
      ),
    );
  }
}
