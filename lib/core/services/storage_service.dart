
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String> uploadFile(String filePath, String fileName) async {
    try {
      File file = File(filePath);
      TaskSnapshot snapshot = await _storage.ref('uploads/$fileName').putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error uploading file: $e");
    }
  }

  // Download a file from Firebase Storage
  Future<String> downloadFile(String fileName) async {
    try {
      String downloadUrl = await _storage.ref('uploads/$fileName').getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error downloading file: $e");
    }
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String fileName) async {
    try {
      await _storage.ref('uploads/$fileName').delete();
    } catch (e) {
      throw Exception("Error deleting file: $e");
    }
  }
}
