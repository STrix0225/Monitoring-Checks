import 'package:cloud_firestore/cloud_firestore.dart';

class DailyTarget {
  final String targetId;
  final String productName;
  final String category;
  final int quantity;
  final String customer;
  final DateTime targetDate;
  final String createdBy;
  final DateTime createdAt;
  final int currentProgress;
  final String status;
  final List<String> assignedTo;
  final DateTime? completedAt;

  DailyTarget({
    required this.targetId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.customer,
    required this.targetDate,
    required this.createdBy,
    required this.createdAt,
    this.currentProgress = 0,
    this.status = 'active',
    required this.assignedTo,
    this.completedAt,
  });

  factory DailyTarget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DailyTarget(
      targetId: data['targetId'],
      productName: data['productName'],
      category: data['category'],
      quantity: data['quantity'],
      customer: data['customer'],
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      currentProgress: data['currentProgress'] ?? 0,
      status: data['status'] ?? 'active',
      assignedTo: List<String>.from(data['assignedTo'] ?? []),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetId': targetId,
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'customer': customer,
      'targetDate': Timestamp.fromDate(targetDate),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'currentProgress': currentProgress,
      'status': status,
      'assignedTo': assignedTo,
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  double get progressPercentage {
  if (quantity <= 0) return 0;
  return (currentProgress / quantity) * 100;
}

bool get isActive => status == 'active';
bool get isCompleted => status == 'completed';
bool get isCancelled => status == 'cancelled';
}