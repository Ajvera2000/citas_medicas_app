import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  String? id;
  String patientName;
  String doctorName;
  DateTime date;
  String notes;
  String status;
  String userId;
  Timestamp? createdAt;

  Appointment({
    this.id,
    required this.patientName,
    required this.doctorName,
    required this.date,
    this.notes = '',
    this.status = 'pendiente',
    required this.userId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'doctorName': doctorName,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'status': status,
      'userId': userId,
      if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Appointment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Appointment(
      id: doc.id,
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'pendiente',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
