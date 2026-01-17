// lib/services/qc_service.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:monitoringng2/models/qc_record_model.dart';
import 'package:monitoringng2/models/checkpoint_model.dart';
import 'package:monitoringng2/models/ng_item_model.dart';
import 'package:monitoringng2/utils/constants.dart';

class QCService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get checkpoints for a specific category
  Future<List<Checkpoint>> getCheckpointsByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection(AppConstants.globalCheckpointsCollection)
          .where('applicableCategories', arrayContains: category)
          .get();

      return snapshot.docs
          .map((doc) => Checkpoint.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting checkpoints: $e');
      return [];
    }
  }

  // Create QC Record
  Future<String> createQCRecord({
    String? qcIdOverride,
    required String targetId,
    required String picId,
    required String picName,
    required String productName,
    required String category,
    required Map<String, CheckpointResult> checkpointResults,
    required String status,
    List<String> photoUrls = const [],
    String? notes,
  }) async {
    try {
      final qcId = qcIdOverride ?? 'QC-${DateTime.now().millisecondsSinceEpoch}';
      final qcTimestamp = DateTime.now();

      // Convert checkpoint results to map
      final checkpointResultsMap = <String, Map<String, dynamic>>{};
      checkpointResults.forEach((key, value) {
        checkpointResultsMap[key] = value.toMap();
      });

      // Determine failed points
      final failedPoints = checkpointResults.entries
          .where((entry) => !entry.value.isPass)
          .map((entry) => entry.key)
          .toList();

      // Create QC Record
      final qcRecord = QCRecord(
        qcId: qcId,
        targetId: targetId,
        picId: picId,
        productName: productName,
        category: category,
        qcTimestamp: qcTimestamp,
        status: status,
        checkpointResults: checkpointResults,
        failedPoints: failedPoints,
        photoUrls: photoUrls,
        notes: notes,
      );

      final batch = _db.batch();

      // 1. Add QC record
      final qcRef = _db.collection(AppConstants.qcRecordsCollection).doc(qcId);
      batch.set(qcRef, qcRecord.toMap());

      // 2. Update target progress (only if status is OK)
      if (status == AppConstants.qcOk) {
        // Resolve the correct target document reference. First try by docId,
        // then fall back to querying by the field `targetId` to support legacy docs.
        final collection = _db.collection(AppConstants.dailyTargetsCollection);
        DocumentReference<Map<String, dynamic>> targetRef = collection.doc(targetId);
        DocumentSnapshot<Map<String, dynamic>> targetDoc = await targetRef.get();
        if (!targetDoc.exists) {
          final q = await collection.where('targetId', isEqualTo: targetId).limit(1).get();
          if (q.docs.isEmpty) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'not-found',
              message: 'Target with id $targetId not found',
            );
          }
          targetRef = q.docs.first.reference;
          targetDoc = await targetRef.get();
        }

        batch.update(targetRef, {
          'currentProgress': FieldValue.increment(1),
        });

        // Check if target is completed
        final targetData = targetDoc.data() ?? {};
        final currentProgress = (targetData['currentProgress'] ?? 0) + 1;
        final quantity = targetData['quantity'] ?? 0;

        if (currentProgress >= quantity) {
          batch.update(targetRef, {
            'status': AppConstants.targetCompleted,
            'completedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // 3. Create NG Item if status is NG
      if (status == AppConstants.qcNg) {
        final ngId = 'NG-${DateTime.now().millisecondsSinceEpoch}';
        final ngRef = _db.collection(AppConstants.ngItemsCollection).doc(ngId);

        final reason = notes ??
            checkpointResults.entries
                .where((entry) => !entry.value.isPass)
                .map((entry) => entry.key.replaceAll('_', ' '))
                .join(', ');

        final ngItem = NGItem(
          ngId: ngId,
          qcId: qcId,
          targetId: targetId,
          productName: productName,
          category: category,
          picId: picId,
          picName: picName,
          ngTimestamp: qcTimestamp,
          photoUrls: photoUrls,
          reason: reason,
          failedPoints: failedPoints,
          status: AppConstants.ngPending,
        );

        batch.set(ngRef, ngItem.toMap());
      }

      // 4. Create activity log
      final logRef = _db.collection('activity_logs').doc();
      batch.set(logRef, {
        'logId': logRef.id,
        'userId': picId,
        'userName': picName,
        'action': 'QC_CHECK',
        'targetType': 'qc_records',
        'targetId': qcId,
        'details': 'Melakukan QC untuk $productName - Status: $status',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return qcId;
    } catch (e) {
      print('Error creating QC record: $e');
      rethrow;
    }
  }

  // Upload QC photos (parallel upload for faster processing)
  Future<List<String>> uploadQCPhotos(
    List<String> filePaths,
    String qcId,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Upload all photos in parallel
    final uploadFutures = filePaths.asMap().entries.map((entry) async {
      final i = entry.key;
      final filePath = entry.value;
      try {
        final fileName = '${timestamp}_$i.jpg';
        final ref = _storage.ref().child('${AppConstants.qcPhotosPath}/$qcId/$fileName');

        // Upload file
        await ref.putFile(File(filePath));
        final url = await ref.getDownloadURL();
        return url;
      } catch (e) {
        print('Error uploading photo $i: $e');
        return null;
      }
    }).toList();

    final urls = await Future.wait(uploadFutures);
    return urls.whereType<String>().toList();
  }

  // Upload QC photos using bytes (web-compatible, parallel upload)
  Future<List<String>> uploadQCPhotosWithBytes(
    List<Uint8List> photoBytes,
    String qcId,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Upload all photos in parallel
    final uploadFutures = photoBytes.asMap().entries.map((entry) async {
      final i = entry.key;
      final bytes = entry.value;
      try {
        final fileName = '${timestamp}_$i.jpg';
        final ref = _storage.ref().child('${AppConstants.qcPhotosPath}/$qcId/$fileName');

        // Upload using putData (works on both web and mobile)
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        final url = await ref.getDownloadURL();
        return url;
      } catch (e) {
        print('Error uploading photo $i: $e');
        return null;
      }
    }).toList();

    final urls = await Future.wait(uploadFutures);
    return urls.whereType<String>().toList();
  }

  // Validate checkpoint value
  static bool validateCheckpointValue(
    Checkpoint checkpoint,
    dynamic value,
  ) {
    if (checkpoint.isRequired && value == null) {
      return false;
    }

    switch (checkpoint.type) {
      case CheckpointType.boolean:
        // For boolean checkpoints: true = OK (pass), false = NG (fail)
        return value == true;
      case CheckpointType.number:
        final numValue = value as num;
        if (checkpoint.minValue != null && numValue < checkpoint.minValue!) {
          return false;
        }
        if (checkpoint.maxValue != null && numValue > checkpoint.maxValue!) {
          return false;
        }
        return true;
      case CheckpointType.text:
        return value is String && value.isNotEmpty;
    }
  }

  // Get QC records by PIC
  Stream<List<QCRecord>> getQCRecordsByPIC(String picId, {int limit = 50}) {
    return _db
        .collection(AppConstants.qcRecordsCollection)
        .where('picId', isEqualTo: picId)
        .orderBy('qcTimestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QCRecord.fromFirestore(doc))
            .toList());
  }

  // Get today's QC count
  Future<int> getTodayQCCount(String picId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _db
        .collection(AppConstants.qcRecordsCollection)
        .where('picId', isEqualTo: picId)
        .where('qcTimestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();

    return snapshot.docs.length;
  }
}