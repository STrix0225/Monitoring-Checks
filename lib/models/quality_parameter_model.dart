class QualityParameter {
  final String id;
  final String category;
  final String product;
  final List<ProductParameter> parameters;
  final DateTime createdAt;
  final DateTime updatedAt;

  QualityParameter({
    required this.id,
    required this.category,
    required this.product,
    required this.parameters,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QualityParameter.fromJson(Map<String, dynamic> json) {
    return QualityParameter(
      id: json['_id'] ?? json['id'] ?? '',
      category: json['category'] ?? '',
      product: json['product'] ?? '',
      parameters: (json['parameters'] is List)
          ? (json['parameters'] as List)
              .map((p) => ProductParameter.fromJson(p is String ? jsonDecode(p) : p))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'product': product,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ProductParameter {
  final String name;
  final String standard;
  final String? tolerance;
  final String type; // "numeric", "boolean", "text"
  final String? unit;
  final bool required;

  ProductParameter({
    required this.name,
    required this.standard,
    this.tolerance,
    required this.type,
    this.unit,
    this.required = true,
  });

  factory ProductParameter.fromJson(Map<String, dynamic> json) {
    return ProductParameter(
      name: json['name'] ?? '',
      standard: json['standard'] ?? '',
      tolerance: json['tolerance'],
      type: json['type'] ?? 'text',
      unit: json['unit'],
      required: json['required'] is bool 
          ? json['required'] 
          : json['required']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'standard': standard,
      'tolerance': tolerance,
      'type': type,
      'unit': unit,
      'required': required,
    };
  }
}