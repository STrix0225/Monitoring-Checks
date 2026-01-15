class DailyTargetModel {
  final String id;
  final String customer;
  final String category;
  final String product;
  final int targetQty;
  final int actualQty; // BARU
  final DateTime deliveryDate;
  final String status;
  final DateTime createdAt;

  DailyTargetModel({
    required this.id,
    required this.customer,
    required this.category,
    required this.product,
    required this.targetQty,
    this.actualQty = 0, // DEFAULT 0
    required this.deliveryDate,
    this.status = 'Not Started',
    required this.createdAt,
  });

  factory DailyTargetModel.fromJson(Map<String, dynamic> json) {
    return DailyTargetModel(
      id: json['_id'] ?? json['id'] ?? '',
      customer: json['customer'] ?? '',
      category: json['category'] ?? '',
      product: json['product'] ?? '',
      targetQty: json['target_qty'] is int 
          ? json['target_qty'] 
          : int.tryParse(json['target_qty'].toString()) ?? 0,
      actualQty: json['actual_qty'] is int  // BARU
          ? json['actual_qty'] 
          : int.tryParse(json['actual_qty'].toString()) ?? 0,
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
      'actual_qty': actualQty, // BARU
      'delivery_date': deliveryDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper untuk progress (0-1)
  double get progress {
    if (targetQty == 0) return 0.0;
    return actualQty / targetQty;
  }

  // Auto-update status berdasarkan progress
  String get autoStatus {
    if (actualQty >= targetQty) return 'Completed';
    return 'On Progress';
  }

  // Copy with untuk update
  DailyTargetModel copyWith({
    int? actualQty,
    String? status,
  }) {
    return DailyTargetModel(
      id: id,
      customer: customer,
      category: category,
      product: product,
      targetQty: targetQty,
      actualQty: actualQty ?? this.actualQty,
      deliveryDate: deliveryDate,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}