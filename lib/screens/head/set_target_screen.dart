
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../restapi.dart';

class SetTargetScreen extends StatefulWidget {
  const SetTargetScreen({super.key});

  @override
  State<SetTargetScreen> createState() => _SetTargetScreenState();
}

class _SetTargetScreenState extends State<SetTargetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerController = TextEditingController();
  String? _selectedCategory;
  String? _selectedProduct;
  final TextEditingController _targetController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  final DataService _dataService = DataService();

  // Data kategori dan produk (sama dengan quality_check_screen)
  final Map<String, List<String>> _categoryProducts = {
    'Body parts': [
      'Front pillar upper outer',
      'Front pillar lower outer',
      'Cowl assembly',
      'Wheel house inner/outer subassembly',
      'Rear floor side member subassembly',
    ],
    'Interior parts': [
      'Instrument panel reinforcement',
    ],
    'Exhaust system parts': [
      'Exhaust system',
      'Exhaust manifold',
      'Diesel exhaust gas post-treatment device',
    ],
    'Suspension parts': [
      'Front suspension sub-frame',
      'Trailing arm',
      'Rear axle beam',
      'Engine undercover',
    ],
    'Fuel system parts': [
      'Canister',
      'Fuel inlet pipe',
    ],
  };

  List<String> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _updateAvailableProducts(String? category) {
    setState(() {
      _selectedCategory = category;
      _availableProducts = category != null 
          ? _categoryProducts[category] ?? []
          : [];
      _selectedProduct = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      _showError('Pilih kategori barang');
      return;
    }
    
    if (_selectedProduct == null) {
      _showError('Pilih nama barang');
      return;
    }
    
    if (_selectedDate == null) {
      _showError('Pilih tanggal pengiriman');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _dataService.insertDailyTarget(
        customer: _customerController.text,
        category: _selectedCategory!,
        product: _selectedProduct!,
        targetQty: int.parse(_targetController.text),
        deliveryDate: _selectedDate!,
      );

      print('Insert result: $result');

      if (result != null && result.toString().isNotEmpty && result.toString() != '[]') {
        Navigator.pop(context, true); // Kembali dengan refresh signal
      } else {
        _showError('Gagal menyimpan target');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Target Harian'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Customer/PT
              TextFormField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Nama PT / Customer',
                  hintText: 'Contoh: PT Daihatsu, PT Toyota',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama PT/Customer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Kategori Barang (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori Barang',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categoryProducts.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  _updateAvailableProducts(value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih kategori barang';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Nama Barang (Dropdown - tergantung kategori)
              DropdownButtonFormField<String>(
                value: _selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                  hintText: 'Pilih kategori terlebih dahulu',
                ),
                items: _availableProducts.map((String product) {
                  return DropdownMenuItem<String>(
                    value: product,
                    child: Text(product),
                  );
                }).toList(),
                onChanged: _selectedCategory == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedProduct = value;
                        });
                      },
                validator: (value) {
                  if (_selectedCategory != null && value == null) {
                    return 'Pilih nama barang';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. Target Jumlah (pcs)
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Target Jumlah (pcs)',
                  hintText: 'Contoh: 5000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan target jumlah';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Target harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 5. Tanggal Pengiriman (Date Picker)
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pengiriman',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
                          : '',
                    ),
                    validator: (value) {
                      if (_selectedDate == null) {
                        return 'Pilih tanggal pengiriman';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 6. Tombol Konfirmasi (sama rata, di tengah)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(_isLoading ? 'Menyimpan...' : 'KONFIRMASI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}