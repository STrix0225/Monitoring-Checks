import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitoringng2/models/target_model.dart';
import 'package:monitoringng2/services/firestore_service.dart';

class TargetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<DailyTarget> _activeTargets = [];
  List<DailyTarget> _allTargets = [];
  bool _isLoading = false;
  String? _error;

  List<DailyTarget> get activeTargets => _activeTargets;
  List<DailyTarget> get allTargets => _allTargets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get todayProgress {
    if (_activeTargets.isEmpty) return 0;
    
    final totalProgress = _activeTargets.fold(0, (sum, target) => sum + target.currentProgress);
    final totalQuantity = _activeTargets.fold(0, (sum, target) => sum + target.quantity);
    
    return totalQuantity > 0 ? (totalProgress / totalQuantity * 100) : 0;
  }

  Future<void> loadActiveTargets() async {
    try {
      _isLoading = true;
      notifyListeners();

      _activeTargets = await _firestoreService.getActiveTargets().first;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createDailyTarget({
    required String productName,
    required String category,
    required int quantity,
    required String customer,
    required DateTime targetDate,
    required List<String> assignedTo,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final target = DailyTarget(
        targetId: 'TARGET-${DateTime.now().millisecondsSinceEpoch}',
        productName: productName,
        category: category,
        quantity: quantity,
        customer: customer,
        targetDate: targetDate,
        createdBy: 'head_dept_001', // TODO: Get from auth
        createdAt: DateTime.now(),
        currentProgress: 0,
        status: 'active',
        assignedTo: assignedTo,
      );

      await _firestoreService.createDailyTarget(target);
      
      // Refresh data
      await loadActiveTargets();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTargetProgress(String targetId, int newProgress) async {
    try {
      await _firestoreService.updateTargetProgress(targetId, newProgress);
      await loadActiveTargets(); // Refresh
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

 Stream<List<DailyTarget>> getTargetsByPICStream(String picCode) {
  return _firestoreService.getTargetsByPIC(picCode);
}


  Future<void> completeTarget(String targetId) async {
    try {
      final target = await _firestoreService.getTarget(targetId);
      if (target != null) {
        await updateTargetProgress(targetId, target.quantity);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<Map<String, int>> getPICStats(String picCode) async {
  try {
    // Get today's QC count - filter by date in-memory to avoid composite index
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    // Get all QC records for this PIC, filter by date in-memory
    final qcSnapshot = await FirebaseFirestore.instance
        .collection('qcRecord')
        .where('picId', isEqualTo: picCode)
        .get();
    
    // Filter today's records in-memory
    final todayQCs = qcSnapshot.docs.where((doc) {
      final timestamp = (doc.data()['qcTimestamp'] as Timestamp?)?.toDate();
      return timestamp != null && timestamp.isAfter(startOfDay);
    }).toList();
    
    // Get ALL NG items for this PIC (not just pending)
    final ngSnapshot = await FirebaseFirestore.instance
        .collection('ngItems')
        .where('picId', isEqualTo: picCode)
        .get();
    final totalNGs = ngSnapshot.docs.length;
    
    return {
      'totalQCToday': todayQCs.length,
      'okQCToday': todayQCs.where((doc) => doc.data()['status'] == 'OK').length,
      'ngItems': totalNGs,
    };
  } catch (e) {
    print('Error getting PIC stats: $e');
    return {'totalQCToday': 0, 'okQCToday': 0, 'ngItems': 0};
  }
 }
}