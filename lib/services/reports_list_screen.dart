import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

 
  Future<void> _markAsFound(String reportId) async {
    try {
      await FirebaseFirestore.instance.collection('lost_dogs').doc(reportId).update({
        'found': true, 
      });
      print("✅ Reporte $reportId marcado como encontrado");
    } catch (e) {
      print("❌ Error al marcar como encontrado: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser; // 

    return Scaffold(
      appBar: AppBar(title: const Text("📜 Mis Reportes")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lost_dogs')
            .where('userId', isEqualTo: user?.uid) // 🔹 Filtrar solo los reportes del usuario actual
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("❌ No tienes reportes aún."));
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final reportId = reports[index].id;
              final timestamp = report['timestamp'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate())
                  : "Fecha desconocida";
              final bool found = report['found'] ?? false;

              print("📌 Reporte cargado: ${report['name']} - Encontrado: $found");

              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      leading: report['imageUrl'] != null && report['imageUrl'].toString().isNotEmpty
                          ? Image.network(
                              report['imageUrl'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.pets, size: 50),
                      title: Text(report['name'] ?? "Nombre Desconocido"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📅 Reportado el: $formattedDate"),
                          Text("📍 Ubicación: ${report['latitude']}, ${report['longitude']}"),
                          Text("🐾 Raza: ${report['breed'] ?? 'Desconocida'}"),
                          Text("🎨 Color: ${report['color'] ?? 'No especificado'}"),
                          if (found)
                            const Text("✅ Este perro ya fue encontrado", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    if (!found)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _markAsFound(reportId);
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text("Marcar como encontrado"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
