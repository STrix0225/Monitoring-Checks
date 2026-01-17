import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:monitoringng2/config/firebase_options.dart';

class FirebaseConfig {
  static late FirebaseApp firebaseApp;
  static late FirebaseAuth firebaseAuth;
  static late FirebaseFirestore firestore;
  static late FirebaseStorage storage;

  static Future<void> initializeFirebase() async {
    try {
      // Initialize Firebase with platform-specific options
      firebaseApp = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize services
      firebaseAuth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      storage = FirebaseStorage.instance;

      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }
}