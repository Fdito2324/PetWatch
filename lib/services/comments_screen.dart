import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentsScreen extends StatefulWidget {
  final String reportId;
  const CommentsScreen({Key? key, required this.reportId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('lost_dogs')
        .doc(widget.reportId)
        .collection('comments')
        .add({
      'userId': user.uid,
      'userName': user.displayName ?? 'Anónimo',
      'comment': commentText,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
    });
    _commentController.clear();
  }

  Future<void> _likeComment(String commentId) async {
    await _firestore
        .collection('lost_dogs')
        .doc(widget.reportId)
        .collection('comments')
        .doc(commentId)
        .update({'likes': FieldValue.increment(1)});
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comentarios")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('lost_dogs')
                  .doc(widget.reportId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay comentarios."));
                }
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var commentData = comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(commentData['comment'] ?? ""),
                      subtitle: Text(
                        "${commentData['userName'] ?? 'Anónimo'} - ${_formatTimestamp(commentData['timestamp'])} - Likes: ${commentData['likes'] ?? 0}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.thumb_up),
                        onPressed: () => _likeComment(comments[index].id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Agrega un comentario...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
