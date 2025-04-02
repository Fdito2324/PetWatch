import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
          body: Center(child: Text("No estás autenticado.")));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Reportes"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lost_dogs')
            .where('userId', isEqualTo: currentUser.uid)
           
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tienes reportes."));
          }
          final reports = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;
              Timestamp? timestamp = data['timestamp'] as Timestamp?;
              String formattedDate = timestamp != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate())
                  : "Sin fecha";
              bool found = data['found'] ?? false;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: (data['imageUrls'] != null &&
                          data['imageUrls'] is List &&
                          (data['imageUrls'] as List).isNotEmpty)
                      ? Image.network(
                          (data['imageUrls'] as List)[0],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        )
                      : const Icon(Icons.pets, size: 50),
                  title: Text(data['name'] ?? "Sin nombre"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Fecha: $formattedDate"),
                      Text("Estado: ${found ? "Encontrado" : "Pendiente"}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
