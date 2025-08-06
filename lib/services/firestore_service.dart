import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _coleccion = 'notas';

  Future<void> agregarNota(String tipo, String contenido, DateTime fecha) async {
    await _db.collection(_coleccion).add({
      'contenido': contenido,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
    });
  }

  Future<void> actualizarNota(String id, String contenido, String tipo) async {
    await _db.collection(_coleccion).doc(id).update({
      'contenido': contenido,
      'tipo': tipo,
    });
  }

  Future<void> eliminarNota(String id) async {
    await _db.collection(_coleccion).doc(id).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> leerNotas() {
    return _db.collection(_coleccion).orderBy('fecha', descending: true).snapshots();
  }
}
