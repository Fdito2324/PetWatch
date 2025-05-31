import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("No estás autenticado.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text("Mis Conversaciones"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new_conversation');
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_comment),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tienes conversaciones."));
          }

          final conversations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final data = conversation.data() as Map<String, dynamic>;

              final otherUserId = (data['participants'] as List)
                  .firstWhere((id) => id != currentUser.uid);
              final otherUserName = data['names']?[otherUserId] ?? 'Usuario';

              final lastMessage = data['lastMessage'] ?? 'Sin mensajes';
              final timestamp = data['lastTimestamp'] as Timestamp?;
              final formattedTime = timestamp != null
                  ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
                  : '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId: conversation.id,
                          otherUserName: otherUserName,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade400,
                    child: Text(
                      otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    otherUserName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
