import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitoringng2/models/user_model.dart';
import 'package:monitoringng2/models/target_model.dart';
import 'package:monitoringng2/models/qc_record_model.dart';
import 'package:monitoringng2/models/ng_item_model.dart';
import 'package:monitoringng2/utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ USERS ============
  Future<void> createUser(UserModel user) async {
    await _db.collection(AppConstants.usersCollection)
        .doc(user.userId)
        .set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection(AppConstants.usersCollection)
        .doc(userId)
        .get();
    
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<List<UserModel>> getAllPICs() async {
    final snapshot = await _db.collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.pic)
        .where('isActive', isEqualTo: true)
        .get();
    
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // ============ DAILY TARGETS ============
  Future<String> createDailyTarget(DailyTarget target) async {
    // Use targetId as the Firestore document ID so other services
    // can reliably reference the document by `targetId`.
    final docRef =
        _db.collection(AppConstants.dailyTargetsCollection).doc(target.targetId);
    await docRef.set(target.toMap());
    return docRef.id;
  }

  Future<void> updateTargetProgress(String targetId, int newProgress) async {
    // Try to update by document ID first; if it doesn't exist, look up by field `targetId`.
    final collection = _db.collection(AppConstants.dailyTargetsCollection);
    DocumentReference<Map<String, dynamic>> docRef = collection.doc(targetId);

    DocumentSnapshot<Map<String, dynamic>> snap = await docRef.get();
    if (!snap.exists) {
      final query = await collection.where('targetId', isEqualTo: targetId).limit(1).get();
      if (query.docs.isEmpty) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Target with id $targetId not found',
        );
      }
      docRef = query.docs.first.reference;
      snap = await docRef.get();
    }

    final data = snap.data() ?? {};
    final int quantity = (data['quantity'] ?? 0) as int;

    await docRef.update({
      'currentProgress': newProgress,
      'status': newProgress >= quantity
          ? AppConstants.targetCompleted
          : AppConstants.targetActive,
      if (newProgress >= quantity) 'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DailyTarget?> getTarget(String targetId) async {
    final collection = _db.collection(AppConstants.dailyTargetsCollection);
    // Try fetch by document ID first
    final byId = await collection.doc(targetId).get();
    if (byId.exists) {
      return DailyTarget.fromFirestore(byId);
    }
    // Fallback: fetch by field `targetId` (for older documents created with random IDs)
    final query = await collection.where('targetId', isEqualTo: targetId).limit(1).get();
    if (query.docs.isNotEmpty) {
      return DailyTarget.fromFirestore(query.docs.first);
    }
    return null;
  }

  Stream<List<DailyTarget>> getActiveTargets() {
    return _db.collection(AppConstants.dailyTargetsCollection)
        .where('status', isEqualTo: AppConstants.targetActive)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyTarget.fromFirestore(doc))
            .toList());
  }

  Stream<List<DailyTarget>> getTargetsByPIC(String picCode) {
  return _db.collection(AppConstants.dailyTargetsCollection)
      .where('assignedTo', arrayContains: picCode)
      .where('status', isEqualTo: AppConstants.targetActive)
      // Remove orderBy to avoid composite index - sort in memory instead
      .snapshots()
      .map((snapshot) {
        final targets = snapshot.docs
            .map((doc) => DailyTarget.fromFirestore(doc))
            .toList();
        // Sort by targetDate in ascending order (earliest first)
        targets.sort((a, b) => a.targetDate.compareTo(b.targetDate));
        return targets;
      });
}


  // ============ QC RECORDS ============
  Future<String> createQCRecord(QCRecord record) async {
    final docRef = _db.collection(AppConstants.qcRecordsCollection).doc();
    await docRef.set(record.toMap());
    return docRef.id;
  }

  Future<List<QCRecord>> getQCRecordsByTarget(String targetId) async {
    final snapshot = await _db.collection(AppConstants.qcRecordsCollection)
        .where('targetId', isEqualTo: targetId)
        .get();
    
    final records = snapshot.docs.map((doc) => QCRecord.fromFirestore(doc)).toList();
    // Sort by qcTimestamp descending (newest first) in-memory
    records.sort((a, b) => b.qcTimestamp.compareTo(a.qcTimestamp));
    return records;
  }

  Stream<List<QCRecord>> getTodayQCRecords(String picId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return _db.collection(AppConstants.qcRecordsCollection)
        .where('picId', isEqualTo: picId)
        .snapshots()
        .map((snapshot) {
          // Filter by today's date in-memory to avoid composite index
          final records = snapshot.docs
              .map((doc) => QCRecord.fromFirestore(doc))
              .where((record) => record.qcTimestamp.isAfter(startOfDay))
              .toList();
          // Sort by qcTimestamp descending (newest first)
          records.sort((a, b) => b.qcTimestamp.compareTo(a.qcTimestamp));
          return records;
        });
  }

  // ============ NG ITEMS ============
  Future<String> createNGItem(NGItem item) async {
    final docRef = _db.collection(AppConstants.ngItemsCollection).doc();
    await docRef.set(item.toMap());
    return docRef.id;
  }

  Future<void> updateNGItemStatus(String ngId, String status, String confirmedBy) async {
    await _db.collection(AppConstants.ngItemsCollection)
        .doc(ngId)
        .update({
          'status': status,
          'confirmedBy': confirmedBy,
          'confirmedAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<NGItem>> getPendingNGItems() {
    return _db
      .collection(AppConstants.ngItemsCollection)
      .where('status', isEqualTo: AppConstants.ngPending)
      // Avoid composite index requirement on web: sort in memory
      .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => NGItem.fromFirestore(doc))
              .toList();
          items.sort((a, b) => b.ngTimestamp.compareTo(a.ngTimestamp));
          return items;
        });
  }

  // ============ CATEGORIES & CHECKPOINTS ============
  Future<List<String>> getCategories() async {
    final snapshot = await _db.collection(AppConstants.categoriesCollection).get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getCheckpointsByCategory(String category) async {
    final snapshot = await _db.collection(AppConstants.globalCheckpointsCollection)
        .where('applicableCategories', arrayContains: category)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ============ STATISTICS ============
  Future<Map<String, dynamic>> getDashboardStats() async {
    final targetsSnapshot = await _db.collection(AppConstants.dailyTargetsCollection)
        .where('status', isEqualTo: AppConstants.targetActive)
        .get();
    
    final ngItemsSnapshot = await _db.collection(AppConstants.ngItemsCollection)
        .where('status', isEqualTo: AppConstants.ngPending)
        .get();
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final qcTodaySnapshot = await _db.collection(AppConstants.qcRecordsCollection)
        .where('qcTimestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();
    
    final totalQCToday = qcTodaySnapshot.docs.length;
    final okQCToday = qcTodaySnapshot.docs
        .where((doc) => doc['status'] == AppConstants.qcOk)
        .length;
    
    return {
      'activeTargets': targetsSnapshot.docs.length,
      'pendingNGItems': ngItemsSnapshot.docs.length,
      'totalQCToday': totalQCToday,
      'okQCToday': okQCToday,
      'qcSuccessRate': totalQCToday > 0 ? (okQCToday / totalQCToday * 100) : 0,
    };
  }
}