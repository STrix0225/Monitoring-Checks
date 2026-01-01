import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:monitoringng1/restapi.dart';
import 'package:monitoringng1/config.dart' as ApiConfig;
import 'package:monitoringng1/models/daily_target_model.dart';

class QualityCheckScreenV2 extends StatefulWidget {
  final DailyTargetModel target;
  final String picId;

  const QualityCheckScreenV2({
    super.key,
    required this.target,
    required this.picId,
  });

  @override
  State<QualityCheckScreenV2> createState() => _QualityCheckScreenV2State();
}

class _QualityCheckScreenV2State extends State<QualityCheckScreenV2> {
  final DataService _dataService = DataService();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<Map<String, dynamic>> _parameters = [];
  Map<String, dynamic> _checkResults = {};
  Map<String, List<XFile>> _ngImages = {};
  Map<String, TextEditingController> _ngReasonControllers = {};
  Map<String, String> _actualValues = {};
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _overallStatus = 'OK';
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQualityParameters();
  }

  Future<void> _loadQualityParameters() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _dataService.getQualityParametersByProduct(
        widget.target.category,
        widget.target.product,
      );
      
      final data = jsonDecode(response);
      
      if (data['data'] != null && data['data']['parameters'] != null) {
        setState(() {
          _parameters = List<Map<String, dynamic>>.from(data['data']['parameters']);
          
          // Initialize check results
          for (var param in _parameters) {
            final paramName = param['name'];
            _checkResults[paramName] = {
              'passed': true,
              'type': param['type'] ?? 'boolean',
            };
            
            // Initialize NG image list
            _ngImages[paramName] = <XFile>[];
            
            // Initialize NG reason controller
            _ngReasonControllers[paramName] = TextEditingController();
            
            // Initialize actual value if numeric type
            if ((param['type'] ?? 'boolean') == 'numeric') {
              _actualValues[paramName] = '';
            }
          }
        });
      }
    } catch (e) {
      print('Error loading quality parameters: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _takePhoto(String paramName) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
      );
      
      if (photo != null && mounted) {
        setState(() {
          _ngImages[paramName]!.add(photo);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil diambil'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickPhoto(String paramName) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      
      if (photo != null && mounted) {
        setState(() {
          _ngImages[paramName]!.add(photo);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil dipilih'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> _uploadNgPhotos(List<XFile> photos) async {
    List<String> uploadedFileNames = [];
    
    for (var photo in photos) {
      try {
        final fileBytes = await photo.readAsBytes();
        final fileName = await _dataService.upload(
          ApiConfig.token,
          ApiConfig.project,
          fileBytes,
          photo.path.split('.').last,
        );
        
        uploadedFileNames.add(fileName);
      } catch (e) {
        print('Error uploading photo: $e');
      }
    }
    
    return uploadedFileNames;
  }

  Future<void> _submitQualityCheck() async {
    // Validasi
    bool hasNg = _checkResults.values.any((result) => !result['passed']);
    
    if (hasNg) {
      // Validasi untuk parameter NG
      for (var param in _parameters) {
        final paramName = param['name'];
        if (!_checkResults[paramName]!['passed']) {
          // Cek apakah ada foto untuk parameter NG
          if (_ngImages[paramName]!.isEmpty) {
            _showError('Foto wajib diupload untuk parameter NG: $paramName');
            return;
          }
          
          // Cek apakah ada alasan NG
          if (_ngReasonControllers[paramName]!.text.isEmpty) {
            _showError('Alasan NG wajib diisi untuk parameter: $paramName');
            return;
          }
        }
      }
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      // 1. Upload foto-foto NG
      List<String> allPhotoUrls = [];
      List<String> ngReasons = [];
      
      for (var param in _parameters) {
        final paramName = param['name'];
        
        if (!_checkResults[paramName]!['passed']) {
          // Upload foto untuk parameter ini
          final photoUrls = await _uploadNgPhotos(_ngImages[paramName]!);
          allPhotoUrls.addAll(photoUrls);
          
          // Tambahkan alasan NG
          ngReasons.add('${paramName}: ${_ngReasonControllers[paramName]!.text}');
        }
      }
      
      // 2. Prepare parameters data
      List<Map<String, dynamic>> parametersData = [];
      
      for (var param in _parameters) {
        final paramName = param['name'];
        final paramType = param['type'] ?? 'boolean';
        
        Map<String, dynamic> paramData = {
          'name': paramName,
          'standard': param['standard'] ?? '',
          'passed': _checkResults[paramName]!['passed'],
        };
        
        if (paramType == 'numeric') {
          paramData['actual'] = _actualValues[paramName] ?? '';
          paramData['unit'] = param['unit'] ?? '';
        }
        
        parametersData.add(paramData);
      }
      
      // 3. Tentukan overall status
      final overallStatus = hasNg ? 'NG' : 'OK';
      
      // 4. Insert ke database
      final result = await _dataService.insertQualityCheckResult(
        targetId: widget.target.product,
        picId: widget.picId,
        productName: widget.target.product,
        category: widget.target.category,
        customer: widget.target.customer,
        status: overallStatus,
        parameters: parametersData,
        ngReasons: ngReasons,
        photos: allPhotoUrls,
        notes: _notesController.text,
      );
      
      if (result != '[]') {
        _showSuccess('Quality Check berhasil disimpan!');
        Navigator.pop(context);
      } else {
        _showError('Gagal menyimpan Quality Check');
      }
    } catch (e) {
      print('Error submitting QC: $e');
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildParameterItem(Map<String, dynamic> param) {
    final paramName = param['name'];
    final standard = param['standard'] ?? '';
    final paramType = param['type'] ?? 'boolean';
    final isPassed = _checkResults[paramName]!['passed'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  paramName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Std: $standard',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Input field berdasarkan tipe
            if (paramType == 'numeric')
              _buildNumericField(paramName, param)
            else if (paramType == 'text')
              _buildTextField(paramName)
            else
              const SizedBox(), // Boolean hanya menggunakan toggle
            
            const SizedBox(height: 12),
            
            // Status toggle
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _checkResults[paramName]!['passed'] = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isPassed ? Colors.green : Colors.grey,
                      side: BorderSide(
                        color: isPassed ? Colors.green : Colors.grey,
                      ),
                      backgroundColor: isPassed ? Colors.green[50] : null,
                    ),
                    child: const Text('OK'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _checkResults[paramName]!['passed'] = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: !isPassed ? Colors.red : Colors.grey,
                      side: BorderSide(
                        color: !isPassed ? Colors.red : Colors.grey,
                      ),
                      backgroundColor: !isPassed ? Colors.red[50] : null,
                    ),
                    child: const Text('NG'),
                  ),
                ),
              ],
            ),
            
            // NG Details jika status NG
            if (!isPassed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DETAIL BARANG NG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Alasan NG
                    TextField(
                      controller: _ngReasonControllers[paramName],
                      decoration: const InputDecoration(
                        labelText: 'Alasan NG (Detail kerusakan)',
                        border: OutlineInputBorder(),
                        hintText: 'Contoh: Penyok di bagian cylinder sebesar 5mm',
                      ),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Upload Foto
                    _buildPhotoUploadSection(paramName),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumericField(String paramName, Map<String, dynamic> param) {
    return TextField(
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _actualValues[paramName] = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Nilai Aktual (${param['unit'] ?? ''})',
        border: const OutlineInputBorder(),
        hintText: 'Masukkan nilai pengukuran',
      ),
    );
  }

  Widget _buildTextField(String paramName) {
    return TextField(
      onChanged: (value) {
        setState(() {
          _actualValues[paramName] = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Keterangan',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPhotoUploadSection(String paramName) {
    final photos = _ngImages[paramName]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Bukti NG (Wajib):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        if (photos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
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
                        child: Image.file(
                          File(photos[index].path),
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
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            photos.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
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
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _takePhoto(paramName),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Foto'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickPhoto(paramName),
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih dari Galeri'),
              ),
            ),
          ],
        ),
        
        if (photos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '⚠️ Minimal 1 foto wajib diupload',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Check'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'PIC: ${widget.picId}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Produk: ${widget.target.product}'),
                          Text('Customer: ${widget.target.customer}'),
                          Text('Kategori: ${widget.target.category}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Parameters List
                  const Text(
                    'PARAMETER QUALITY CHECK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ..._parameters.map(_buildParameterItem).toList(),
                  
                  // Notes
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Catatan Tambahan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Masukkan catatan tambahan jika ada...',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitQualityCheck,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SIMPAN QUALITY CHECK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}