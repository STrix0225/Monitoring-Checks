import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitoringng2/models/user_model.dart';
import 'package:monitoringng2/utils/constants.dart';
class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase Authentication
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Get user data from Firestore
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      // If user document is missing, create a minimal profile so login proceeds
      if (!userDoc.exists) {
        final uid = credential.user!.uid;
        final emailAddr = credential.user!.email ?? email;
        final name = credential.user!.displayName ?? emailAddr.split('@').first;

        // Tentukan role default berdasarkan email yang diizinkan
        final defaultRole = AppConstants.defaultHeadEmails.contains(emailAddr)
            ? AppConstants.headDept
            : AppConstants.pic;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'userId': uid,
          'name': name,
          'email': emailAddr,
          'role': defaultRole,
          'department': 'QC',
          'specialCode': null,
          'photoUrl': null,
          'createdAt': Timestamp.now(),
          'createdBy': 'system',
          'isActive': true,
        });

        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
      }

      _user = UserModel.fromFirestore(userDoc);
      
      // Check if user is active
      if (!_user!.isActive) {
        throw Exception('Akun tidak aktif. Hubungi kepala departemen.');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> autoLogin() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          _user = UserModel.fromFirestore(userDoc);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}