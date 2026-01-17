// lib/models/ng_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NGItem {
  final String ngId;
  final String qcId;
  final String targetId;
  final String productName;
  final String category;
  final String picId;
  final String picName;
  final DateTime ngTimestamp;
  final List<String> photoUrls;
  final String reason;
  final List<String> failedPoints;
  final String status; // 'pending', 'confirmed_for_melt', 'melted'
  final String? confirmedBy;
  final DateTime? confirmedAt;
  final String? meltLocation;
  final DateTime? meltTimestamp;

  NGItem({
    required this.ngId,
    required this.qcId,
    required this.targetId,
    required this.productName,
    required this.category,
    required this.picId,
    required this.picName,
    required this.ngTimestamp,
    required this.photoUrls,
    required this.reason,
    this.failedPoints = const [],
    this.status = 'pending',
    this.confirmedBy,
    this.confirmedAt,
    this.meltLocation,
    this.meltTimestamp,
  });

  factory NGItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NGItem(
      ngId: data['ngId'],
      qcId: data['qcId'],
      targetId: data['targetId'],
      productName: data['productName'],
      category: data['category'],
      picId: data['picId'],
      picName: data['picName'] ?? '',
      ngTimestamp: (data['ngTimestamp'] as Timestamp).toDate(),
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      reason: data['reason'],
      failedPoints: List<String>.from(data['failedPoints'] ?? []),
      status: data['status'] ?? 'pending',
      confirmedBy: data['confirmedBy'],
      confirmedAt: data['confirmedAt'] != null 
          ? (data['confirmedAt'] as Timestamp).toDate()
          : null,
      meltLocation: data['meltLocation'],
      meltTimestamp: data['meltTimestamp'] != null
          ? (data['meltTimestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ngId': ngId,
      'qcId': qcId,
      'targetId': targetId,
      'productName': productName,
      'category': category,
      'picId': picId,
      'picName': picName,
      'ngTimestamp': Timestamp.fromDate(ngTimestamp),
      'photoUrls': photoUrls,
      'reason': reason,
      'failedPoints': failedPoints,
      'status': status,
      'confirmedBy': confirmedBy,
      'confirmedAt': confirmedAt != null 
          ? Timestamp.fromDate(confirmedAt!)
          : null,
      'meltLocation': meltLocation,
      'meltTimestamp': meltTimestamp != null
          ? Timestamp.fromDate(meltTimestamp!)
          : null,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmedForMelt => status == 'confirmed_for_melt';
  bool get isMelted => status == 'melted';

  @override
  String toString() {
    return 'NGItem(product: $productName, reason: $reason, status: $status)';
  }
}