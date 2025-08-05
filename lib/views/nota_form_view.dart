import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class NotaFormView extends StatefulWidget {
  final String coleccion;
  final String? id;
  final String? tituloInicial;
  final String? contenidoInicial;

  const NotaFormView({
    super.key,
    required this.coleccion,
    this.id,
    this.tituloInicial,
    this.contenidoInicial,
  });

  @override
  State<NotaFormView> createState() => _NotaFormViewState();
}

class _NotaFormViewState extends State<NotaFormView> {
  late TextEditingController tituloCtrl;
  late TextEditingController contenidoCtrl;

  @override
  void initState() {
    super.initState();
    tituloCtrl = TextEditingController(text: widget.tituloInicial);
    contenidoCtrl = TextEditingController(text: widget.contenidoInicial);
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    contenidoCtrl.dispose();
    super.dispose();
  }

  void _guardar() async {
    final t = tituloCtrl.text.trim();
    final c = contenidoCtrl.text.trim();
    if (t.isEmpty || c.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      if (widget.id == null) {
        await FirestoreService().agregarNota(widget.coleccion, t, c);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota guardada')));
      } else {
        await FirestoreService().actualizarNota(widget.coleccion, widget.id!, t, c);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nota actualizada')));
      }
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.id == null ? 'Agregar Nota' : 'Editar Nota'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tituloCtrl,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          TextField(
            controller: contenidoCtrl,
            decoration: const InputDecoration(labelText: 'Contenido'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: Text(widget.id == null ? 'Guardar' : 'Actualizar'),
        ),
      ],
    );
  }
}
