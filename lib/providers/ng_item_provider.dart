// lib/providers/ng_item_provider.dart
import 'package:flutter/material.dart';
import 'package:monitoringng2/models/ng_item_model.dart';
import 'package:monitoringng2/services/firestore_service.dart';

class NGItemProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<NGItem> _pendingItems = [];
  List<NGItem> _allItems = [];
  bool _isLoading = false;
  String? _error;

  List<NGItem> get pendingItems => _pendingItems;
  List<NGItem> get allItems => _allItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPendingItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      _pendingItems = await _firestoreService.getPendingNGItems().first;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> confirmForMelt(String ngId, String confirmedBy) async {
    try {
      await _firestoreService.updateNGItemStatus(
        ngId,
        'confirmed_for_melt',
        confirmedBy,
      );
      
      // Refresh list
      await loadPendingItems();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Stream<List<NGItem>> getPendingItemsStream() {
    return _firestoreService.getPendingNGItems();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}