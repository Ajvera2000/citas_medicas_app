import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'appointments';

  // Stream filtrado por userId, con orden por fecha
  Stream<List<Appointment>> streamAppointmentsForUser(String uid, {int limit = 50}) {
    return _db
        .collection(collectionPath)
        .where('userId', isEqualTo: uid)
        .orderBy('date')
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => Appointment.fromDoc(d)).toList());
  }

  Future<List<Appointment>> getAppointmentsForUserOnce(String uid, {int limit = 200}) async {
    final q = await _db
        .collection(collectionPath)
        .where('userId', isEqualTo: uid)
        .orderBy('date')
        .limit(limit)
        .get();
    return q.docs.map((d) => Appointment.fromDoc(d)).toList();
  }

  Future<Appointment> getById(String id) async {
    final doc = await _db.collection(collectionPath).doc(id).get();
    return Appointment.fromDoc(doc);
  }

  Future<void> addAppointment(Appointment a) async {
    await _db.collection(collectionPath).add(a.toMap());
  }

  Future<void> updateAppointment(Appointment a) async {
    if (a.id == null) throw Exception('ID nulo');
    final map = a.toMap();
    // Avoid overwriting createdAt with serverTimestamp on update - remove that field
    map.remove('createdAt');
    await _db.collection(collectionPath).doc(a.id).update(map);
  }

  Future<void> deleteAppointment(String id) async {
    await _db.collection(collectionPath).doc(id).delete();
  }

  // Verifica conflicto exacto de fecha/hora para el mismo doctor (exact timestamp)
  Future<bool> doctorHasConflict(String doctorName, DateTime date, {String? excludingId}) async {
    final ts = Timestamp.fromDate(date);
    Query q = _db.collection(collectionPath)
      .where('doctorName', isEqualTo: doctorName)
      .where('date', isEqualTo: ts);
    final snapshot = await q.get();
    if (snapshot.docs.isEmpty) return false;
    if (excludingId == null) return true;
    // si hay docs pero solo la misma que estamos editando -> no conflicto
    return snapshot.docs.any((d) => d.id != excludingId);
  }

  // Filtrado simple: por doctor, por estado, por rango de fechas
  Future<List<Appointment>> filterAppointments(String uid, {String? doctor, String? status, DateTime? from, DateTime? to}) async {
    Query q = _db.collection(collectionPath).where('userId', isEqualTo: uid);
    if (doctor != null && doctor.isNotEmpty) q = q.where('doctorName', isEqualTo: doctor);
    if (status != null && status.isNotEmpty) q = q.where('status', isEqualTo: status);
    if (from != null) q = q.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    if (to != null) q = q.where('date', isLessThanOrEqualTo: Timestamp.fromDate(to));
    final snapshot = await q.orderBy('date').get();
    return snapshot.docs.map((d) => Appointment.fromDoc(d)).toList();
  }
}
