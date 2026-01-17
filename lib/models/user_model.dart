import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { headDept, pic }

class UserModel {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final String? specialCode;
  final String? photoUrl;
  final DateTime createdAt;
  final String createdBy;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.specialCode,
    this.photoUrl,
    required this.createdAt,
    required this.createdBy,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    UserRole role;
    switch (data['role']) {
      case 'head_dept':
        role = UserRole.headDept;
        break;
      case 'pic':
        role = UserRole.pic;
        break;
      default:
        role = UserRole.pic;
    }

    return UserModel(
      userId: data['userId'],
      name: data['name'],
      email: data['email'],
      role: role,
      department: data['department'],
      specialCode: data['specialCode'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    String roleString;
    switch (role) {
      case UserRole.headDept:
        roleString = 'head_dept';
        break;
      case UserRole.pic:
        roleString = 'pic';
        break;
    }

    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': roleString,
      'department': department,
      'specialCode': specialCode,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  bool get isHeadDept => role == UserRole.headDept;
  bool get isPIC => role == UserRole.pic;

  @override
  String toString() {
    return 'UserModel(userId: $userId, name: $name, role: $role)';
  }
}