// lib/models/qc_record_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckpointResult {
  final dynamic value;
  final bool isPass;
  final bool isRequired;
  final bool isFilled;
  final double? min;
  final double? max;

  CheckpointResult({
    required this.value,
    required this.isPass,
    required this.isRequired,
    required this.isFilled,
    this.min,
    this.max,
  });

  factory CheckpointResult.fromMap(Map<String, dynamic> map) {
    return CheckpointResult(
      value: map['value'],
      isPass: map['isPass'],
      isRequired: map['isRequired'],
      isFilled: map['isFilled'],
      min: map['min'],
      max: map['max'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'isPass': isPass,
      'isRequired': isRequired,
      'isFilled': isFilled,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
    };
  }
}

class QCRecord {
  final String qcId;
  final String targetId;
  final String picId;
  final String productName;
  final String category;
  final DateTime qcTimestamp;
  final String status; // OK or NG
  final Map<String, CheckpointResult> checkpointResults;
  final List<String> failedPoints;
  final List<String> photoUrls;
  final String? notes;

  QCRecord({
    required this.qcId,
    required this.targetId,
    required this.picId,
    required this.productName,
    required this.category,
    required this.qcTimestamp,
    required this.status,
    required this.checkpointResults,
    this.failedPoints = const [],
    this.photoUrls = const [],
    this.notes,
  });

  factory QCRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert checkpointResults map
    final checkpointResultsMap = <String, CheckpointResult>{};
    if (data['checkpointResults'] != null) {
      final results = data['checkpointResults'] as Map<String, dynamic>;
      results.forEach((key, value) {
        checkpointResultsMap[key] = CheckpointResult.fromMap(Map<String, dynamic>.from(value));
      });
    }

    return QCRecord(
      qcId: data['qcId'],
      targetId: data['targetId'],
      picId: data['picId'],
      productName: data['productName'],
      category: data['category'],
      qcTimestamp: (data['qcTimestamp'] as Timestamp).toDate(),
      status: data['status'],
      checkpointResults: checkpointResultsMap,
      failedPoints: List<String>.from(data['failedPoints'] ?? []),
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    // Convert checkpointResults to map
    final checkpointResultsMap = <String, Map<String, dynamic>>{};
    checkpointResults.forEach((key, value) {
      checkpointResultsMap[key] = value.toMap();
    });

    return {
      'qcId': qcId,
      'targetId': targetId,
      'picId': picId,
      'productName': productName,
      'category': category,
      'qcTimestamp': Timestamp.fromDate(qcTimestamp),
      'status': status,
      'checkpointResults': checkpointResultsMap,
      'failedPoints': failedPoints,
      'photoUrls': photoUrls,
      'notes': notes,
    };
  }

  bool get isOk => status == 'OK';
  bool get isNg => status == 'NG';
  int get totalCheckpoints => checkpointResults.length;
  int get passedCheckpoints => checkpointResults.values.where((r) => r.isPass).length;

  @override
  String toString() {
    return 'QCRecord(product: $productName, status: $status, time: $qcTimestamp)';
  }
}