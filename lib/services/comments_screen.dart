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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        title: const Text("Comentarios"),
        centerTitle: true,
      ),
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final data = comment.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['userName'] ?? 'Anónimo',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(data['comment'] ?? ''),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTimestamp(data['timestamp']),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Row(
                                  children: [
                                    Text('${data['likes'] ?? 0}'),
                                    IconButton(
                                      onPressed: () => _likeComment(comment.id),
                                      icon: const Icon(Icons.favorite_border),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Escribe un comentario...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
