import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile_picture_widget.dart';
import 'profile_text_field.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _cityController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  String? _profileImageUrl;
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        _fullNameController.text = doc.data()?['fullName'] ?? '';
        _emailController.text = doc.data()?['email'] ?? user.email ?? '';
        _contactNumberController.text = doc.data()?['contactNumber'] ?? '';
        _cityController.text = doc.data()?['city'] ?? '';
        _profileImageUrl = doc.data()?['profileImageUrl'];
        _isEditing = true;
      } else {
        _emailController.text = user.email ?? '';
      }
    } catch (e) {
      _showError('Error loading profile: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _profileImageUrl;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Create unique filename with timestamp
      final fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      // Start upload
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask;

      // Get download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _showError('Error uploading image: ${e.toString()}');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final imageUrl = await _uploadImage();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'contactNumber': _contactNumberController.text,
        'city': _cityController.text,
        'profileImageUrl': imageUrl ?? _profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showSuccess('Profile saved successfully!');
      Navigator.pop(context, true); // Return success flag
    } catch (e) {
      _showError('Error saving profile: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF007C85);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ProfilePictureWidget(
                        imageUrl: _profileImageUrl,
                        onImageSelected: (file) {
                          setState(() => _imageFile = file);
                        },
                      ),
                      const SizedBox(height: 30),
                      ProfileTextField(
                        label: 'Full Name',
                        controller: _fullNameController,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please enter your full name'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      ProfileTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ProfileTextField(
                        label: 'Contact Number',
                        controller: _contactNumberController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      ProfileTextField(
                        label: 'City',
                        controller: _cityController,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isEditing ? 'Update Profile' : 'Create Profile',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
