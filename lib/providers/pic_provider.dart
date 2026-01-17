import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:monitoringng2/utils/constants.dart';

class Pic {
  final String id;
  final String name;
  final String department;

  Pic({
    required this.id,
    required this.name,
    required this.department,
  });

  factory Pic.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Pic(
      id: doc.id,
      name: (data['name'] ?? data['fullname'] ?? '').toString().isEmpty
          ? 'Unnamed'
          : (data['name'] ?? data['fullname']).toString(),
      department: (data['department'] ?? data['dept'] ?? '-').toString(),
    );
  }
}

class PicProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName;
  List<Pic> _pics = [];
  StreamSubscription<QuerySnapshot>? _sub;

  PicProvider({this.collectionName = 'pics'}) {
    _listen();
  }

  void _listen() {
    Stream<QuerySnapshot> stream;

    // If using default 'pics' collection, read from users collection and
    // filter by role == pic. This keeps backward compatibility if another
    // collection name is explicitly provided.
    if (collectionName == 'pics') {
      stream = _db
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: AppConstants.pic)
          .snapshots();
    } else {
      stream = _db.collection(collectionName).snapshots();
    }

    _sub = stream.listen((snapshot) {
      _pics = snapshot.docs.map((d) => Pic.fromDoc(d)).toList();
      notifyListeners();
    }, onError: (err) {
      // ignore errors silently; you can log if needed
    });
  }

  List<Pic> get pics => List.unmodifiable(_pics);

  Future<void> addPic(Map<String, dynamic> data) async {
    await _db.collection(collectionName).add(data);
  }

  Future<void> removePic(String id) async {
    await _db.collection(collectionName).doc(id).delete();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}