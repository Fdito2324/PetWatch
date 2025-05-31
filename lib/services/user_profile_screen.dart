import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  Uint8List? _profileImage;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get _user => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      _nameController.text = _user!.displayName ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final Uint8List bytes = await picked.readAsBytes();
      setState(() {
        _profileImage = bytes;
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null || _user == null) return null;
    try {
      final ref = _storage.ref().child("profile_photos/${_user!.uid}.jpg");
      final snapshot = await ref.putData(
        _profileImage!,
        SettableMetadata(contentType: "image/jpeg"),
      );
      if (snapshot.state == TaskState.success) {
        String downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      print("Error uploading profile image: $e");
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      String? photoUrl = await _uploadProfileImage();

      await _user!.updateDisplayName(_nameController.text);
      if (photoUrl != null) {
        await _user!.updatePhotoURL(photoUrl);
      }
      await _user!.reload();

      await _firestore.collection('users').doc(_user!.uid).update({
        'nombre': _nameController.text,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado exitosamente")),
      );
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar el perfil: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Perfil del Usuario",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
          elevation: 4,
        ),
        body: const Center(child: Text("No se encontró el usuario.")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Perfil del Usuario",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? MemoryImage(_profileImage!)
                    : (_user!.photoURL != null
                        ? NetworkImage(_user!.photoURL!) as ImageProvider
                        : const AssetImage("assets/default_profile.png")),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(Icons.camera_alt, size: 20, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _user!.email),
              decoration: InputDecoration(
                labelText: "Correo",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_alt_rounded),
                    label: const Text(
                      "Guardar cambios",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
