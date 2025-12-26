class ProductItem {
  final String id;
  final String name;
  final String customer;
  final DateTime checkDate;
  final bool isOk;
  final String? issue; // Untuk barang NG

  ProductItem({
    required this.id,
    required this.name,
    required this.customer,
    required this.checkDate,
    required this.isOk,
    this.issue,
  });

  factory ProductItem.fromJson(Map<String, dynamic> data) {
    return ProductItem(
      id: data['_id'] ?? data['id'] ?? '',
      name: data['name'] ?? data['nama'] ?? '',
      customer: data['customer'] ?? '',
      checkDate: data['checkDate'] != null 
        ? DateTime.parse(data['checkDate']) 
        : DateTime.now(),
      isOk: data['isOk'] ?? data['is_ok'] ?? true,
      issue: data['issue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'customer': customer,
      'checkDate': checkDate.toIso8601String(),
      'isOk': isOk,
      'issue': issue,
    };
  }
}
