
class DailyTargetModel {
  final String customer;        // PT yang memesan
  final String category;        // Kategori barang
  final String product;         // Nama barang
  final int targetQty;          // Target jumlah (pcs)
  final DateTime deliveryDate;  // Tanggal pengiriman
  final String status;          // Status: On Track, Late, Completed
  final DateTime createdAt;     // Waktu dibuat

  DailyTargetModel({
    required this.customer,
    required this.category,
    required this.product,
    required this.targetQty,
    required this.deliveryDate,
    this.status = 'Not Started',
    required this.createdAt,
  });

  factory DailyTargetModel.fromJson(Map<String, dynamic> json) {
    return DailyTargetModel(
      customer: json['customer'] ?? '',
      category: json['category'] ?? '',
      product: json['product'] ?? '',
      targetQty: json['target_qty'] is int 
          ? json['target_qty'] 
          : int.tryParse(json['target_qty'].toString()) ?? 0,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'])
          : DateTime.now(),
      status: json['status'] ?? 'Not Started',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customer,
      'category': category,
      'product': product,
      'target_qty': targetQty,
      'delivery_date': deliveryDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper untuk status progress
  double get progress {
    // Untuk sementara 0, nanti bisa dihitung dari actual QC
    return 0.0;
  }

  bool get isOnTrack => status == 'On Track';
  bool get isLate => status == 'Late';
  bool get isCompleted => status == 'Completed';
}