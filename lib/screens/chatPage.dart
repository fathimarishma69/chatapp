import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String currentUserEmail;
  final String selectedUserEmail;

  const ChatPage({
    super.key,
    required this.currentUserEmail,
    required this.selectedUserEmail,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Scroll controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white), // Placeholder for avatar
            ),
            const SizedBox(width: 10),
            Text(widget.selectedUserEmail),
          ],
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: true) // Sort messages in descending order
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final messages = snapshot.data!.docs.where((message) {
                  final messageData = message.data() as Map<String, dynamic>;
                  final sender = messageData['sender'];
                  final receiver = messageData['receiver'];

                  return (sender == widget.currentUserEmail &&
                      receiver == widget.selectedUserEmail) ||
                      (sender == widget.selectedUserEmail &&
                          receiver == widget.currentUserEmail);
                }).toList();

                // Scroll to the bottom when messages are loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController, // Attach scroll controller
                  itemCount: messages.length,
                  reverse: true, // Reverse to show latest at the bottom
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final isMe = messageData['sender'] == widget.currentUserEmail;
                    final messageText = messageData['message'] ?? '';
                    final timestamp = messageData['timestamp'] != null
                        ? (messageData['timestamp'] as Timestamp).toDate()
                        : DateTime.now();

                    return _buildMessageBubble(messageText, isMe, timestamp);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String messageText, bool isMe, DateTime timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isMe ? Colors.purple[200] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: isMe ? const Radius.circular(20) : Radius.zero,
              topRight: !isMe ? const Radius.circular(20) : Radius.zero,
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageText,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                '${timestamp.hour}:${timestamp.minute}', // Format to show time
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attachment, color: Colors.purple),
            onPressed: () {
              // Handle file attachment
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                _sendMessage();
              },
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            child: const Icon(Icons.send, color: Colors.white),
            backgroundColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _firestore.collection('messages').add({
      'sender': widget.currentUserEmail,
      'receiver': widget.selectedUserEmail,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }
}
