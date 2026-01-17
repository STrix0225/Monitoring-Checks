// lib/views/head_dept/dashboard/create_target_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitoringng2/providers/target_provider.dart';
import 'package:monitoringng2/utils/constants.dart';

class CreateTargetScreen extends StatefulWidget {
  const CreateTargetScreen({super.key});

  @override
  State<CreateTargetScreen> createState() => _CreateTargetScreenState();
}

class _CreateTargetScreenState extends State<CreateTargetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _customerController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedProduct;
  DateTime? _selectedDate;
  List<String> _selectedPICs = [];

  List<String> _categories = AppConstants.categories;
  List<String> _availableProducts = [];
  List<Map<String, dynamic>> _availablePICs = [];

  @override
  void initState() {
    super.initState();
    _loadPICs();
  }

  Future<void> _loadPICs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'pic')
        .where('isActive', isEqualTo: true)
        .get();
    
    setState(() {
      _availablePICs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': data['userId'],
          'name': data['name'],
          'specialCode': data['specialCode'],
          'department': data['department'],
        };
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal target terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedPICs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 PIC'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      final targetProvider = Provider.of<TargetProvider>(context, listen: false);
      
      await targetProvider.createDailyTarget(
        productName: _selectedProduct!,
        category: _selectedCategory!,
        quantity: int.parse(_quantityController.text),
        customer: _customerController.text,
        targetDate: _selectedDate!,
        assignedTo: _selectedPICs,
      );
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Target Harian'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Dropdown - First
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori Barang',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedProduct = null; // Reset product when category changes
                    _availableProducts = AppConstants.productsByCategory[value] ?? [];
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Kategori harus dipilih';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Product Dropdown - Second
              DropdownButtonFormField<String>(
                value: _selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  hintText: 'Pilih kategori terlebih dahulu',
                ),
                items: _availableProducts.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(product),
                  );
                }).toList(),
                onChanged: _selectedCategory == null ? null : (value) {
                  setState(() {
                    _selectedProduct = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Nama barang harus dipilih';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (pcs)',
                  hintText: 'Contoh: 100',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Customer
              TextFormField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  hintText: 'Contoh: PT Honda',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Customer harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Target Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Target',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Pilih tanggal',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Assigned PICs
              const Text(
                'PIC yang Ditugaskan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              
              if (_availablePICs.isNotEmpty) ...[
                ..._availablePICs.map((pic) {
                  final isSelected = _selectedPICs.contains(pic['specialCode']);
                  return CheckboxListTile(
                    title: Text('${pic['specialCode']} - ${pic['name']}'),
                    subtitle: Text(pic['department']),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedPICs.add(pic['specialCode']);
                        } else {
                          _selectedPICs.remove(pic['specialCode']);
                        }
                      });
                    },
                  );
                }).toList(),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Tidak ada PIC yang tersedia'),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN TARGET',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customerController.dispose();
    super.dispose();
  }
}