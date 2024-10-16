import 'package:chatapp/screens/chatPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;  // To store the current logged-in user

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Get current logged-in user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[200],
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs.map((doc) {
            return {
              'name': doc['name'],
              'email': doc['email'],
              'username': doc['username'],
              'createdAt': doc['createdAt'],
            };
          }).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              // Avoid displaying the current user in the chat list
              if (_currentUser?.email == users[index]['email']) {
                return const SizedBox.shrink(); // Skip current user
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(users[index]['name']),
                  subtitle: Text(users[index]['username']),  // Display username
                  trailing: const Text('2:30 PM'),
                  onTap: () {
                    // Navigate to the ChatPage with both the current and selected user emails
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(currentUserEmail: _currentUser?.email ?? 'Unknown User',
                          selectedUserEmail: users[index]['email'],

                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle chat creation
        },
        child: const Icon(Icons.chat),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
