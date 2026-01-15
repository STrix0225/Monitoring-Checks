import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import untuk kIsWeb
import 'dart:convert';
import 'package:monitoringng1/models/daily_target_model.dart';
import 'package:monitoringng1/restapi.dart';

// quality_check_screen.dart - Update class:
class QualityCheckScreen extends StatefulWidget {
  final DailyTargetModel target;  // BARU: Terima target
  final String picId;

  const QualityCheckScreen({
    super.key,
    required this.target,
    required this.picId,
  });

  @override
  State<QualityCheckScreen> createState() => _QualityCheckScreenState();
}

class _QualityCheckScreenState extends State<QualityCheckScreen> {
  final Map<String, dynamic> _checkResults = {};
  final Map<String, List<XFile>> _ngImages = {};
  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();
  final DataService _dataService = DataService(); // BARU: Tambah DataService
  
  String? _selectedCategory;
  String? _selectedProduct;
  List<String> _availableProducts = [];
  
  List<Map<String, dynamic>> _qualityParameters = []; // BARU: Parameter dari database
  
  // Default category->products (used for dropdown when API not available)
  final Map<String, List<String>> _categoryProducts = {
    'Body Parts': [
      'Front pillar upper outer',
      'Cowl assembly',
      'Front pillar',
      'Cowl assembly',
    ],
    'Interior Parts': [
      'Dash Panel',
      'Seat Frame',
    ],
  };

  // Default quality items (fallback)
  final List<Map<String, String>> _defaultQualityItems = [
    {'name': 'Ketebalan', 'standard': '3.0 mm'},
    {'name': 'Penyok', 'standard': 'Tidak ada'},
    {'name': 'Diameter lubang', 'standard': '12.5 mm'},
    {'name': 'Panjang', 'standard': '450 mm'},
    {'name': 'Sudut potong', 'standard': '45°'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Set kategori dan produk dari target
    setState(() {
      _selectedCategory = widget.target.category;
      _selectedProduct = widget.target.product;
    });
    
    // Load quality parameters dari database
    _loadQualityParameters();
  }
  
  // BARU: Method untuk load quality parameters
  Future<void> _loadQualityParameters() async {
    try {
      final response = await _dataService.getQualityParametersByProduct(
        widget.target.category,
        widget.target.product,
      );
      
      final responseApi = jsonDecode(response);
      if (responseApi['data'] != null) {
        final data = responseApi['data'];
        if (data['parameters'] != null) {
          // Parse parameters
          final params = data['parameters'];
          if (params is String) {
            _qualityParameters = List<Map<String, dynamic>>.from(jsonDecode(params));
          } else if (params is List) {
            _qualityParameters = List<Map<String, dynamic>>.from(params);
          }
          
          // Inisialisasi checkResults dengan parameter dari database
          for (var param in _qualityParameters) {
            _checkResults[param['name']] = {
              'value': '',
              'passed': true,
              'type': param['type'] ?? 'text',
              'standard': param['standard'] ?? '',
              'tolerance': param['tolerance'] ?? '',
              'unit': param['unit'] ?? '',
            };
            _ngImages[param['name']] = [];
          }
          
          setState(() {});
        }
      }
    } catch (e) {
      print('Error loading quality parameters: $e');
      // Fallback ke default parameters jika error
      _useDefaultParameters();
    }
  }
  
  // Fallback ke default parameters
  void _useDefaultParameters() {
    final List<Map<String, String>> _defaultQualityItems = [
      {'name': 'Ketebalan', 'standard': '3.0 mm'},
      {'name': 'Penyok', 'standard': 'Tidak ada'},
      {'name': 'Diameter lubang', 'standard': '12.5 mm'},
      {'name': 'Panjang', 'standard': '450 mm'},
      {'name': 'Sudut potong', 'standard': '45°'},
    ];
    
    for (var item in _defaultQualityItems) {
      _checkResults[item['name']!] = {
        'value': '',
        'passed': true,
        'type': _determineItemType(item['name']!),
        'standard': item['standard']!,
      };
      _ngImages[item['name']!] = [];
    }
  }

  // ... (sisanya sama, tapi gunakan _qualityParameters, bukan _defaultQualityItems)

  // Update _buildCheckItem untuk menggunakan parameter dari database
  Widget _buildCheckItem(String itemName, String standardValue) {
    final images = _ngImages[itemName] ?? [];
    final type = _checkResults[itemName]?['type'] ?? _determineItemType(itemName);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Standard: $standardValue',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            if (type == 'numeric') _buildNumericInput(itemName) else const SizedBox.shrink(),

            const SizedBox(height: 12),
            _buildStatusToggle(itemName, images),
          ],
        ),
      ),
    );
  }

  // BARU: Method untuk submit QC dengan update actual_qty
  void _submitCheck() async {
    // Validasi
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _showError('Pilih kategori produk');
      return;
    }
    
    if (_selectedProduct == null || _selectedProduct!.isEmpty) {
      _showError('Pilih produk');
      return;
    }

    // Validasi parameter numeric
    for (var entry in _checkResults.entries) {
      final param = _qualityParameters.firstWhere(
        (p) => p['name'] == entry.key,
        orElse: () => {},
      );
      
      if (param['type'] == 'numeric' && 
          (entry.value['value'] == null || entry.value['value'].toString().isEmpty)) {
        _showError('Isi nilai aktual untuk ${entry.key}');
        return;
      }
      
      if (entry.value['passed'] == false) {
        final images = _ngImages[entry.key] ?? [];
        if (images.isEmpty) {
          _showError('Wajib upload foto bukti untuk item NG: ${entry.key}');
          return;
        }
      }
    }
    

    setState(() => _isSubmitting = true);

    try {
      // 1. Siapkan parameters untuk disimpan
      List<Map<String, dynamic>> parameters = [];
      List<String> ngReasons = [];
      
      for (var entry in _checkResults.entries) {
        parameters.add({
          'name': entry.key,
          'standard': entry.value['standard'],
          'actual': entry.value['value'],
          'passed': entry.value['passed'],
        });
        
        if (entry.value['passed'] == false) {
          ngReasons.add('${entry.key}: ${entry.value['value']} (Standard: ${entry.value['standard']})');
        }
      }
      
      // 2. Siapkan photos
      List<String> photoPaths = [];
      for (var entry in _ngImages.entries) {
        for (var image in entry.value) {
          photoPaths.add(image.path);
        }
      }
      
      // 3. Tentukan status
      final allPassed = _checkResults.values.every((result) => result['passed'] == true);
      final status = allPassed ? 'OK' : 'NG';
      
      // 4. Simpan ke quality_check_results
      await _dataService.insertQualityCheckResult(
        targetId: widget.target.id,
        picId: widget.picId,
        productName: widget.target.product,
        category: widget.target.category,
        customer: widget.target.customer,
        status: status,
        parameters: parameters,
        ngReasons: ngReasons,
        photos: photoPaths,
        notes: '', // Tambahkan field notes jika perlu
      );
      
      // 5. Jika OK, update actual_qty
      if (status == 'OK') {
        int newActualQty = widget.target.actualQty + 1;
        
        // Update actual_qty di database
        await _dataService.updateDailyTargetActualQty(
          widget.target.id, 
          newActualQty
        );
        
        // Update status jika sudah mencapai target
        if (newActualQty >= widget.target.targetQty) {
          await _dataService.updateDailyTargetStatus(widget.target.id, 'Completed');
        }
      }
      
      // 6. Tampilkan success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quality Check berhasil disimpan. Status: $status'),
            backgroundColor: status == 'OK' ? Colors.green : Colors.orange,
          ),
        );
        
        // Kembali ke dashboard
        Navigator.pop(context);
      }
      
    } catch (e) {
      print('Error submitting QC: $e');
      _showError('Gagal menyimpan QC: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _determineItemType(String itemName) {
    if (itemName.toLowerCase().contains('ketebalan') || 
        itemName.toLowerCase().contains('diameter') ||
        itemName.toLowerCase().contains('panjang') ||
        itemName.toLowerCase().contains('sudut')) {
      return 'numeric';
    }
    return 'boolean'; 
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

  Future<void> _takePhotoFromCamera(String itemName) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (photo != null && mounted) {
        setState(() {
          _ngImages[itemName]!.add(photo);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto berhasil diambil dari kamera')),
        );
      }
    } catch (e) {
      print('Error mengambil foto dari kamera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickPhotoFromGallery(String itemName) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      
      if (photo != null && mounted) {
        setState(() {
          _ngImages[itemName]!.add(photo);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto berhasil dipilih dari galeri')),
        );
      }
    } catch (e) {
      print('Error memilih foto dari galeri: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: ${e.toString()}')),
      );
    }
  }

  void _showImageSourceDialog(String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: const Text('Pilih sumber untuk mengambil gambar bukti:'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _takePhotoFromCamera(itemName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Kamera'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pickPhotoFromGallery(itemName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text('Galeri'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
        ],
      ),
    );
  }

  void _removeImage(String itemName, int index) {
    setState(() {
      _ngImages[itemName]!.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gambar berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Quality Check'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PIC: ${widget.picId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Tanggal: ${DateTime.now().toString().substring(0, 10)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text('DATA PRODUK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Produk',
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
                        if (value == null || value.isEmpty) {
                          return 'Pilih kategori produk';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      items: _availableProducts.map((String product) {
                        return DropdownMenuItem<String>(
                          value: product,
                          child: Text(product),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProduct = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih produk';
                        }
                        return null;
                      },
                      disabledHint: _selectedCategory == null 
                          ? const Text('Pilih kategori terlebih dahulu')
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text('ITEM PEMERIKSAAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            // Use parameters from DB when available, otherwise fallback to defaults
            ...(_qualityParameters.isNotEmpty
                ? _qualityParameters.map<Widget>((p) {
                    final name = p['name']?.toString() ?? '';
                    final standard = p['standard']?.toString() ?? '';
                    // ensure checkResults entry exists
                    _checkResults.putIfAbsent(name, () => {
                      'value': '',
                      'passed': true,
                      'type': p['type'] ?? 'text',
                      'standard': standard,
                    });
                    _ngImages.putIfAbsent(name, () => []);
                    return _buildCheckItem(name, standard);
                  }).toList()
                : _defaultQualityItems.map<Widget>((item) {
                    final name = item['name']!;
                    final standard = item['standard']!;
                    _checkResults.putIfAbsent(name, () => {
                      'value': '',
                      'passed': true,
                      'type': _determineItemType(name),
                      'standard': standard,
                    });
                    _ngImages.putIfAbsent(name, () => []);
                    return _buildCheckItem(name, standard);
                  }).toList()),
            
            const SizedBox(height: 24),
    
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SIMPAN HASIL QC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNumericInput(String itemName) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Nilai Aktual (mm/deg)',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        setState(() {
          _checkResults[itemName] = {
            ..._checkResults[itemName]!,
            'value': value,
          };
        });
      },
    );
  }

  Widget _buildStatusToggle(String itemName, List<XFile> images) {
    final result = _checkResults[itemName];
    final bool isPassed = result?['passed'] ?? true;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _checkResults[itemName] = {..._checkResults[itemName]!, 'passed': true}),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isPassed ? Colors.green[100] : Colors.grey[100],
                    border: Border.all(color: isPassed ? Colors.green : Colors.transparent),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text('OK / Lulus', 
                      style: TextStyle(color: isPassed ? Colors.green[800] : Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
               child: GestureDetector(
                onTap: () => setState(() => _checkResults[itemName] = {..._checkResults[itemName]!, 'passed': false}),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !isPassed ? Colors.red[100] : Colors.grey[100],
                    border: Border.all(color: !isPassed ? Colors.red : Colors.transparent),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text('NG / Cacat', 
                      style: TextStyle(color: !isPassed ? Colors.red[800] : Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (!isPassed) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Bukti Foto Wajib Diisi!',
                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (images.isNotEmpty)
                  Column(
                    children: [
                      const Text(
                        'Gambar yang sudah diupload:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb
                                        ? Image.network(
                                            images[index].path,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.error, color: Colors.red),
                                              );
                                            },
                                          )
                                        : Image.file(
                                            File(images[index].path),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.error, color: Colors.red),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(itemName, index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showImageSourceDialog(itemName),
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: Text(images.isEmpty ? 'Ambil Foto Bukti' : 'Tambah Foto Lain'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // (kept server-backed `_submitCheck` above; remove duplicate local stub)

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}