import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class ReportLostDogScreen extends StatefulWidget {
  const ReportLostDogScreen({super.key});

  @override
  _ReportLostDogScreenState createState() => _ReportLostDogScreenState();
}

class _ReportLostDogScreenState extends State<ReportLostDogScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  Position? _currentPosition;
  List<Uint8List> _selectedImages = [];
  bool _isUploading = false;

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    colorController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("❌ Servicio de ubicación deshabilitado.");
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("⚠ Permiso de ubicación denegado.");
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ubicación obtenida: ${position.latitude}, ${position.longitude}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final filesData = await Future.wait(
        pickedFiles.map((file) => file.readAsBytes()),
      );
      setState(() => _selectedImages.addAll(filesData));
    }
  }

  Future<void> _uploadReport() async {
    if (_isUploading) return;
    setState(() => _isUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _currentPosition == null) throw Exception("Falta información para enviar el reporte.");

      final reportRef = FirebaseFirestore.instance.collection('lost_dogs').doc();
      final imageUrls = <String>[];

      for (var i = 0; i < _selectedImages.length; i++) {
        final ref = FirebaseStorage.instance.ref().child('lost_dogs/${reportRef.id}_$i.jpg');
        await ref.putData(_selectedImages[i]);
        imageUrls.add(await ref.getDownloadURL());
      }

      await reportRef.set({
        'userId': user.uid,
        'name': nameController.text,
        'breed': breedController.text,
        'color': colorController.text,
        'details': detailsController.text,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reporte enviado exitosamente.')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF009688),
        title: const Text('Reportar Perro Perdido'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField('Nombre del perro', nameController),
            _buildTextField('Raza', breedController),
            _buildTextField('Color', colorController),
            _buildTextField('Detalles adicionales', detailsController),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF009688),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.location_on),
              label: const Text('Obtener ubicación'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.image),
              label: const Text('Seleccionar imágenes'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _selectedImages.map((img) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(img, width: 80, height: 80, fit: BoxFit.cover),
              )).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.send),
              label: Text(_isUploading ? 'Enviando...' : 'Enviar reporte'),
            ),
          ],
        ),
      ),
    );
  }
}
