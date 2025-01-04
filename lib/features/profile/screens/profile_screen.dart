// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
// import 'package:event_pro/features/profile/widgets/profile_info.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late String _username;
  late String _email;
  String? _profilePictureUrl;

  TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _username = _user.displayName ?? 'Anonymous';
    _email = _user.email ?? 'Not available';
    _profilePictureUrl = _user.photoURL;
    _usernameController.text = _username;
  }

  // Update user profile details in Firebase
  Future<void> _updateProfile() async {
    try {
      final newUsername = _usernameController.text;

      if (_profilePictureUrl != _user.photoURL || newUsername != _user.displayName) {
        await _user.updateDisplayName(newUsername);

        if (_profilePictureUrl != null) {
          await _user.updatePhotoURL(_profilePictureUrl);
        }
      }

      // Optionally, you could update Firestore as well
      await FirebaseFirestore.instance.collection('users').doc(_user.uid).set({
        'username': newUsername,
        'email': _email,
        'profilePicture': _profilePictureUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() {
        _username = newUsername;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }

  // Pick and upload new profile image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = pickedFile.path;
      try {
        // Upload the new image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child('${_user.uid}.jpg');
        await storageRef.putFile(File(imageFile));

        final downloadUrl = await storageRef.getDownloadURL();
        setState(() {
          _profilePictureUrl = downloadUrl;
        });

        // Update the user's photoURL in Firebase Auth
        await _user.updatePhotoURL(downloadUrl);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile picture updated')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile picture: ${e.toString()}')));
      }
    }
  }

  // Logout the user
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');  // Adjust according to your route structure
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateProfile, // Save profile changes
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePictureUrl != null
                    ? NetworkImage(_profilePictureUrl!)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
                child: _profilePictureUrl == null
                    ? Icon(Icons.camera_alt, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Username',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter new username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Email',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              _email, // Displaying email
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
