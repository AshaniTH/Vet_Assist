import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileSummary extends StatefulWidget {
  const UserProfileSummary({super.key});

  @override
  State<UserProfileSummary> createState() => _UserProfileSummaryState();
}

class _UserProfileSummaryState extends State<UserProfileSummary> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      setState(() {
        _userData = doc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_userData?['profileImageUrl'] != null)
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(_userData!['profileImageUrl']),
            ),
          const SizedBox(height: 8),
          if (_userData?['fullName'] != null)
            Text(
              _userData!['fullName'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
