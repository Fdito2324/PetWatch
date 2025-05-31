import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class NewConversationScreen extends StatelessWidget {
  const NewConversationScreen({Key? key}) : super(key: key);

  Future<void> _startConversation(
    BuildContext context,
    String otherUserId,
    String otherUserName,
  ) async {
    print("Iniciando conversación con $otherUserName ($otherUserId)");

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Error: Usuario no autenticado");
      return;
    }

    final conversationRef = FirebaseFirestore.instance.collection('conversations');

    try {
      final existing = await conversationRef
          .where('participants', arrayContains: currentUser.uid)
          .get();

      for (final doc in existing.docs) {
        final participants = doc['participants'];
        if (participants.contains(otherUserId)) {
          print("Conversación existente encontrada: ${doc.id}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: doc.id,
                otherUserName: otherUserName,
              ),
            ),
          );
          return;
        }
      }

      // Crear nueva conversación
      final newDoc = await conversationRef.add({
        'participants': [currentUser.uid, otherUserId],
        'names': {
          currentUser.uid: currentUser.displayName ?? 'Tú',
          otherUserId: otherUserName,
        },
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });

      print("Nueva conversación creada: ${newDoc.id}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: newDoc.id,
            otherUserName: otherUserName,
          ),
        ),
      );
    } catch (e) {
      print("Error al iniciar conversación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text("Nueva Conversación"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar los usuarios."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay usuarios registrados."));
          }

          final users = snapshot.data!.docs.where((doc) => doc.id != currentUser?.uid).toList();

          if (users.isEmpty) {
            return const Center(child: Text("No hay otros usuarios disponibles."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final data = user.data() as Map<String, dynamic>;
              final userName = data['nombre'] ?? 'Sin nombre';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () => _startConversation(context, user.id, userName),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chat_bubble_outline),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
