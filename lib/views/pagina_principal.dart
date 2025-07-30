import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> with SingleTickerProviderStateMixin {
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

  void _mostrarDialogo({String? id, String? tituloInit, String? contenidoInit}) {
    final tituloCtrl = TextEditingController(text: tituloInit);
    final contenidoCtrl = TextEditingController(text: contenidoInit);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Agregar Nota' : 'Editar Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: contenidoCtrl, decoration: const InputDecoration(labelText: 'Contenido')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final t = tituloCtrl.text.trim();
              final c = contenidoCtrl.text.trim();
              if (t.isEmpty || c.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todos los campos')));
                return;
              }
              try {
                if (id == null) {
                  await FirestoreService().agregarNota('blog', t, c);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota guardada')));
                } else {
                  await FirestoreService().actualizarNota('blog', id, t, c);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota actualizada')));
                }
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(id == null ? 'Guardar' : 'Actualizar'),
          ),
        ],
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
                await FirestoreService().eliminarNota('blog', id);
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
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(icon: Icon(Icons.public, color: Colors.black), text: 'Blog'),
            Tab(icon: Icon(Icons.lock, color: Colors.black), text: 'Journal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _blogTab(),
          _journalTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogo(),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _blogTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService().leerNotas('blog'),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error al cargar notas', style: TextStyle(color: Colors.black)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No hay notas aún', style: TextStyle(color: Colors.black54)));

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.black26),
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
                    icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
                    onPressed: () => _mostrarDialogo(id: doc.id, tituloInit: title, contenidoInit: content),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black54, size: 20),
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

  Widget _journalTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock, size: 80, color: Colors.black54),
            SizedBox(height: 20),
            Text('Personal Journal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 12),
            Text(
              'Write your private thoughts here.\nYour journal is only for your eyes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
