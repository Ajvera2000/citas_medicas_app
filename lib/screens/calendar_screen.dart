import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/appointment.dart';

class CalendarScreen extends StatefulWidget {
  final List<Appointment> citas;
  CalendarScreen({required this.citas});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  List appointmentsForDay(DateTime day) {
    return widget.citas.where((c) => c.date.year == day.year && c.date.month == day.month && c.date.day == day.day).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020,1,1),
            lastDay: DateTime.utc(2030,12,31),
            focusedDay: _focused,
            selectedDayPredicate: (day) => isSameDay(_selected, day),
            onDaySelected: (sel, foc) => setState(() { _selected = sel; _focused = foc; }),
            eventLoader: (day) => appointmentsForDay(day),
          ),
          Expanded(
            child: _selected == null
                ? Center(child: Text('Seleccione un día'))
                : ListView(
                    children: appointmentsForDay(_selected!).map((a) => ListTile(
                      title: Text(a.patientName),
                      subtitle: Text('${a.doctorName} • ${a.date.hour.toString().padLeft(2,'0')}:${a.date.minute.toString().padLeft(2,'0')}'),
                    )).toList(),
                  ),
          )
        ],
      ),
    );
  }
}
