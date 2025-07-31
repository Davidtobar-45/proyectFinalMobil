import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String tipo) {
    return _db.collection(tipo); // 'blog' o 'diario'
  }

  Future<void> agregarNota(String tipo, String titulo, String contenido) {
    return _getCollection(tipo).add({'titulo': titulo, 'contenido': contenido});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> leerNotas(String tipo) {
    return _getCollection(tipo).orderBy('titulo', descending: true).snapshots();
  }

  Future<void> actualizarNota(String tipo, String docId, String titulo, String contenido) {
    return _getCollection(tipo).doc(docId).update({
      'titulo': titulo,
      'contenido': contenido,
    });
  }

  Future<void> eliminarNota(String tipo, String id) {
    return _getCollection(tipo).doc(id).delete();
  }
}
