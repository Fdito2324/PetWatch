import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({Key? key}) : super(key: key);

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String generateConversationId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join("_");
  }

  Future<void> _startConversation() async {
    String otherEmail = _emailController.text.trim();
    if (otherEmail.isEmpty) return;
    String currentUserId = _auth.currentUser!.uid;

    
    QuerySnapshot userSnapshot = await _firestore
        .collection("users")
        .where("email", isEqualTo: otherEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró un usuario con ese correo.")),
      );
      return;
    }


    String otherUserId = (userSnapshot.docs.first.data() as Map<String, dynamic>)["uid"];
    String conversationId = generateConversationId(currentUserId, otherUserId);

    DocumentReference chatDoc =
        _firestore.collection("chats").doc(conversationId);
    DocumentSnapshot snapshot = await chatDoc.get();
    if (!snapshot.exists) {
      await chatDoc.set({
        "participants": [currentUserId, otherUserId],
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversationId: conversationId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Conversación")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Correo del otro usuario",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startConversation,
              child: const Text("Iniciar Chat"),
            ),
          ],
        ),
      ),
    );
  }
}
