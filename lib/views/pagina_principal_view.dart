import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'nota_form_view.dart';

class PaginaPrincipalView extends StatefulWidget {
  const PaginaPrincipalView({super.key});

  @override
  State<PaginaPrincipalView> createState() => _PaginaPrincipalViewState();
}

class _PaginaPrincipalViewState extends State<PaginaPrincipalView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _coleccionActual => _tabController.index == 0 ? 'blog' : 'diario';

  void _mostrarDialogoNota({String? id, String? titulo, String? contenido}) {
    showDialog(
      context: context,
      builder: (_) => NotaFormView(
        coleccion: _coleccionActual,
        id: id,
        tituloInicial: titulo,
        contenidoInicial: contenido,
      ),
    );
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Nota'),
        content: const Text('¿Seguro que quieres eliminar esta nota?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirestoreService().eliminarNota(_coleccionActual, id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota eliminada')));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue[900],
          labelColor: Colors.blue[900],
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.public), text: 'Blog'),
            Tab(icon: Icon(Icons.lock), text: 'Journal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _notasTab('blog'),
          _notasTab('diario'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoNota(),
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _notasTab(String coleccion) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService().leerNotas(coleccion),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar notas', style: TextStyle(color: Colors.black)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No hay notas aún', style: TextStyle(color: Colors.black54)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(color: Color.fromARGB(255, 0, 0, 0)),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();
            final title = data['titulo'] ?? 'Sin título';
            final content = data['contenido'] ?? '';

            return ListTile(
              title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text(content, style: const TextStyle(color: Colors.black87)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color.fromARGB(255, 5, 182, 35), size: 20),
                    onPressed: () => _mostrarDialogoNota(id: doc.id, titulo: title, contenido: content),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color.fromARGB(255, 167, 0, 0), size: 20),
                    onPressed: () => _confirmarEliminar(doc.id),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
