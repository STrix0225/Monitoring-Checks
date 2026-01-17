import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload profile photo
  Future<String> uploadProfilePhoto(File image, String userId) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Gagal upload foto profil: $e');
    }
  }

  // Upload QC/NG photo
  Future<String> uploadQCPhoto(File image, String qcId, int index) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
      final ref = _storage.ref().child('qc_photos/$qcId/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Gagal upload foto QC: $e');
    }
  }

  // Pick image from gallery
  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Take photo with camera
  Future<File?> takePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Delete photo
  Future<void> deletePhoto(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }
}