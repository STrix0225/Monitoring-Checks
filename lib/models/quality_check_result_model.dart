import 'dart:convert';

class ParameterResult {
  final String name;
  final String standard;
  final String actual;
  final bool passed;

  ParameterResult({
    required this.name,
    required this.standard,
    required this.actual,
    required this.passed,
  });

  factory ParameterResult.fromJson(Map<String, dynamic> json) {
    return ParameterResult(
      name: json['name'] ?? '',
      standard: json['standard'] ?? '',
      actual: json['actual']?.toString() ?? '',
      passed: json['passed'] is bool
          ? json['passed']
          : json['passed']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'standard': standard,
      'actual': actual,
      'passed': passed,
    };
  }
}

class QualityCheckResult {
  final String id;
  final String targetId; // BARU - WAJIB
  final String picId;
  final String productName;
  final String category;
  final String customer;
  final DateTime checkDate;
  final String status;
  final int quantityOk;
  final int quantityNg;
  final List<ParameterResult> parameters;
  final List<String> ngReasons;
  final List<String> photos;
  final String notes;
  final bool confirmed;
  final String? confirmedBy;
  final DateTime? confirmedDate;
  final String? disposition;

  QualityCheckResult({
    required this.id,
    required this.targetId, // BARU
    required this.picId,
    required this.productName,
    required this.category,
    required this.customer,
    required this.checkDate,
    required this.status,
    this.quantityOk = 1,
    this.quantityNg = 0,
    required this.parameters,
    this.ngReasons = const [],
    this.photos = const [],
    this.notes = '',
    this.confirmed = false,
    this.confirmedBy,
    this.confirmedDate,
    this.disposition,
  });

    factory QualityCheckResult.fromJson(Map<String, dynamic> map) {
    return QualityCheckResult(
      id: map['_id'] ?? map['id'] ?? '',
      targetId: map['target_id'] ?? '', // BARU
      picId: map['pic_id'] ?? '',
      productName: map['product_name'] ?? '',
      category: map['category'] ?? '',
      customer: map['customer'] ?? '',
      checkDate: map['check_date'] != null
        ? DateTime.parse(map['check_date'])
        : DateTime.now(),
      status: map['status'] ?? 'OK',
      quantityOk: map['quantity_ok'] is int
        ? map['quantity_ok']
        : int.tryParse(map['quantity_ok']?.toString() ?? '1') ?? 1,
      quantityNg: map['quantity_ng'] is int
        ? map['quantity_ng']
        : int.tryParse(map['quantity_ng']?.toString() ?? '0') ?? 0,
      parameters: (map['parameters'] is List)
        ? (map['parameters'] as List)
          .map((p) => ParameterResult.fromJson(p is String ? json.decode(p) : (p as Map<String, dynamic>)))
          .toList()
        : [],
      ngReasons: (map['ng_reasons'] is List)
        ? (map['ng_reasons'] as List).map((e) => e.toString()).toList()
        : [],
      photos: (map['photos'] is List)
        ? (map['photos'] as List).map((e) => e.toString()).toList()
        : [],
      notes: map['notes'] ?? '',
      confirmed: map['confirmed'] is bool
        ? map['confirmed']
        : map['confirmed']?.toString().toLowerCase() == 'true',
      confirmedBy: map['confirmed_by'],
      confirmedDate: map['confirmed_date'] != null
        ? DateTime.parse(map['confirmed_date'])
        : null,
      disposition: map['disposition'],
    );
    }

  Map<String, dynamic> toJson() {
    return {
      'target_id': targetId, // BARU
      'pic_id': picId,
      'product_name': productName,
      'category': category,
      'customer': customer,
      'check_date': checkDate.toIso8601String(),
      'status': status,
      'quantity_ok': quantityOk,
      'quantity_ng': quantityNg,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'ng_reasons': ngReasons,
      'photos': photos,
      'notes': notes,
      'confirmed': confirmed,
      'confirmed_by': confirmedBy,
      'confirmed_date': confirmedDate?.toIso8601String(),
      'disposition': disposition,
    };
  }
}