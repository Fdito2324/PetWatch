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
      if (!serviceEnabled) {
        throw Exception("❌ Servicio de ubicación deshabilitado.");
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("⚠ Permiso de ubicación denegado.");
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      print("📍 Ubicación obtenida: $_currentPosition");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ubicación obtenida: (${position.latitude}, ${position.longitude})"),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("❌ Error obteniendo la ubicación: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<Uint8List> images = [];
      for (var file in pickedFiles) {
        images.add(await file.readAsBytes());
      }
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("⚠ Debes iniciar sesión para reportar.");
    
    for (int i = 0; i < _selectedImages.length; i++) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("lost_dogs/${DateTime.now().millisecondsSinceEpoch}_$i.jpg");
      final uploadTask = ref.putData(_selectedImages[i], SettableMetadata(contentType: "image/jpeg"));
      final snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state == TaskState.success) {
        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } else {
        throw Exception("❌ Error al subir la imagen número $i.");
      }
    }
    return imageUrls;
  }

  Future<void> _submitReport() async {
    if (_currentPosition == null || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Debes agregar al menos una imagen y obtener la ubicación.")),
      );
      return;
    }
    setState(() {
      _isUploading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("⚠ Debes iniciar sesión para reportar.");
      }
     
      List<String> imageUrls = await _uploadImages();
      await FirebaseFirestore.instance.collection('lost_dogs').add({
        'userId': user.uid,
        'name': nameController.text,
        'breed': breedController.text,
        'color': colorController.text,
        'details': detailsController.text,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'imageUrls': imageUrls, 
        'found': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Reporte enviado con éxito.")),
      );
      Navigator.pop(context);
    } catch (e) {
      print("❌ Error al enviar reporte: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al enviar reporte: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reportar Perro Perdido 🐶")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(labelText: "Raza"),
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: "Color"),
              ),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: "Detalles"),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text("📷 Agregar Imágenes"),
                  ),
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text("📍 Obtener Ubicación"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Mostrar miniaturas de las imágenes seleccionadas
              _selectedImages.isNotEmpty
                  ? SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Image.memory(_selectedImages[index], fit: BoxFit.cover),
                          );
                        },
                      ),
                    )
                  : Container(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isUploading ? null : _submitReport,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text("📤 Enviar Reporte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
