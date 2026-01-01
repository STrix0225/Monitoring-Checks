import 'dart:convert';
class QualityCheckResult {
  final String id;
  final String targetId;
  final String picId;
  final String productName;
  final String category;
  final String customer;
  final DateTime checkDate;
  final String status; // "OK" atau "NG"
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
    required this.targetId,
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

  factory QualityCheckResult.fromJson(Map<String, dynamic> json) {
    return QualityCheckResult(
      id: json['_id'] ?? json['id'] ?? '',
      targetId: json['target_id'] ?? '',
      picId: json['pic_id'] ?? '',
      productName: json['product_name'] ?? '',
      category: json['category'] ?? '',
      customer: json['customer'] ?? '',
      checkDate: json['check_date'] != null 
          ? DateTime.parse(json['check_date'])
          : DateTime.now(),
      status: json['status'] ?? 'OK',
      quantityOk: json['quantity_ok'] is int 
          ? json['quantity_ok'] 
          : int.tryParse(json['quantity_ok']?.toString() ?? '1') ?? 1,
      quantityNg: json['quantity_ng'] is int 
          ? json['quantity_ng'] 
          : int.tryParse(json['quantity_ng']?.toString() ?? '0') ?? 0,
      parameters: (json['parameters'] is List)
          ? (json['parameters'] as List)
              .map((p) => ParameterResult.fromJson(p is String ? jsonDecode(p) : p))
              .toList()
          : [],
      ngReasons: (json['ng_reasons'] is List)
          ? (json['ng_reasons'] as List).map((e) => e.toString()).toList()
          : (json['ng_reasons'] is String)
              ? jsonDecode(json['ng_reasons']).cast<String>()
              : [],
      photos: (json['photos'] is List)
          ? (json['photos'] as List).map((e) => e.toString()).toList()
          : (json['photos'] is String)
              ? jsonDecode(json['photos']).cast<String>()
              : [],
      notes: json['notes'] ?? '',
      confirmed: json['confirmed'] is bool 
          ? json['confirmed'] 
          : json['confirmed']?.toString().toLowerCase() == 'true',
      confirmedBy: json['confirmed_by'],
      confirmedDate: json['confirmed_date'] != null
          ? DateTime.parse(json['confirmed_date'])
          : null,
      disposition: json['disposition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_id': targetId,
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
      actual: json['actual'] ?? '',
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