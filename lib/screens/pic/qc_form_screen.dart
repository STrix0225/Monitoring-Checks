// lib/screens/pic/qc_form_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monitoringng2/models/target_model.dart';
import 'package:monitoringng2/models/checkpoint_model.dart';
import 'package:monitoringng2/models/qc_record_model.dart';
import 'package:monitoringng2/providers/auth_provider.dart';
import 'package:monitoringng2/services/qc_service.dart';
import 'package:monitoringng2/utils/constants.dart';
import 'package:monitoringng2/screens/pic/photo_capture_screen.dart';
import 'package:monitoringng2/widgets/loading_overlay.dart';

class QCFormScreen extends StatefulWidget {
  final DailyTarget target;

  const QCFormScreen({
    super.key,
    required this.target,
  });

  @override
  State<QCFormScreen> createState() => _QCFormScreenState();
}

class _QCFormScreenState extends State<QCFormScreen> {
  final QCService _qcService = QCService();
  final ImagePicker _picker = ImagePicker();
  
  late List<Checkpoint> _checkpoints;
  final Map<String, dynamic> _checkpointValues = {};
  final Map<String, TextEditingController> _textControllers = {};
  final List<String> _photoPaths = [];
  final List<Uint8List> _photoBytes = []; // For web support
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  
  String _notes = '';
  bool _showNGPhotos = false;
  int _currentItemNumber = 1;

  @override
  void initState() {
    super.initState();
    _loadCheckpoints();
    // Initialize with current progress + 1
    _currentItemNumber = widget.target.currentProgress + 1;
  }

  Future<void> _loadCheckpoints() async {
    try {
      // 1) Try loading from Firestore globalCheckpoint
      var fetched = await _qcService.getCheckpointsByCategory(widget.target.category);

      // 2) Fallback to constants if Firestore returns empty
      if (fetched.isEmpty) {
        final allDefaults = AppConstants.defaultCheckpoints
            .map((data) => Checkpoint.fromMap(data))
            .toList();
        fetched = allDefaults
            .where((cp) => cp.applicableCategories.contains(widget.target.category))
            .toList();
      }

      _checkpoints = fetched;

      // Initialize values
      for (var checkpoint in _checkpoints) {
        switch (checkpoint.type) {
          case CheckpointType.boolean:
            _checkpointValues[checkpoint.checkpointId] = true; // Default to OK
            break;
          case CheckpointType.number:
            _checkpointValues[checkpoint.checkpointId] = checkpoint.minValue ?? 0;
            _textControllers[checkpoint.checkpointId] =
                TextEditingController(text: (checkpoint.minValue ?? 0).toString());
            break;
          case CheckpointType.text:
            _checkpointValues[checkpoint.checkpointId] = '';
            _textControllers[checkpoint.checkpointId] = TextEditingController();
            break;
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _photoPaths.add(pickedFile.path);
          _photoBytes.add(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
      );
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _photoPaths.add(pickedFile.path);
          _photoBytes.add(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
      if (index < _photoBytes.length) {
        _photoBytes.removeAt(index);
      }
    });
  }

  void _openPhotoCapture() async {
  final result = await Navigator.push<List<String>>(
    context,
    MaterialPageRoute(
      builder: (context) => const PhotoCaptureScreen(),
    ),
  );
  
  if (result != null && result.isNotEmpty) {
    setState(() {
      _photoPaths.addAll(result);
    });
  }
}

  bool _validateForm() {
    for (var checkpoint in _checkpoints) {
      if (checkpoint.isRequired) {
        final value = _checkpointValues[checkpoint.checkpointId];
        if (value == null || 
            (checkpoint.type == CheckpointType.text && value.toString().isEmpty)) {
          return false;
        }
      }
    }
    return true;
  }

  Map<String, CheckpointResult> _prepareCheckpointResults() {
    final results = <String, CheckpointResult>{};
    
    for (var checkpoint in _checkpoints) {
      final value = _checkpointValues[checkpoint.checkpointId];
      final isValid = QCService.validateCheckpointValue(checkpoint, value);
      
      results[checkpoint.checkpointId] = CheckpointResult(
        value: value,
        isPass: isValid,
        isRequired: checkpoint.isRequired,
        isFilled: value != null && value.toString().isNotEmpty,
        min: checkpoint.minValue,
        max: checkpoint.maxValue,
      );
    }
    
    return results;
  }

  String _determineStatus() {
    final results = _prepareCheckpointResults();
    final hasFailed = results.values.any((result) => !result.isPass);
    
    return hasFailed ? AppConstants.qcNg : AppConstants.qcOk;
  }

  Future<void> _submitQC() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua checkpoint yang wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final status = _determineStatus();
    
    // If NG but no photos, show warning
    if (status == AppConstants.qcNg && _photoPaths.isEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text(
            'Barang dengan status NG wajib memiliki foto bukti. '
            'Lanjutkan tanpa foto?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Lanjut Tanpa Foto'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        setState(() => _showNGPhotos = true);
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final picId = authProvider.user?.userId ?? '';
      final picName = authProvider.user?.name ?? '';

      // Generate a single QC ID for both photos and record
      final qcId = 'QC-${DateTime.now().millisecondsSinceEpoch}';

      // Upload photos if any
      List<String> photoUrls = [];
      if (_photoBytes.isNotEmpty) {
        photoUrls = await _qcService.uploadQCPhotosWithBytes(
          _photoBytes,
          qcId,
        );
      }

      // Prepare checkpoint results
      final checkpointResults = _prepareCheckpointResults();

      // Create QC record
      await _qcService.createQCRecord(
        qcIdOverride: qcId,
        targetId: widget.target.targetId,
        picId: picId,
        picName: picName,
        productName: widget.target.productName,
        category: widget.target.category,
        checkpointResults: checkpointResults,
        status: status,
        photoUrls: photoUrls,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      // Network tasks complete – stop loading before dialog
      setState(() => _isSubmitting = false);

      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QC berhasil disimpan! Status: $status'),
          backgroundColor: status == AppConstants.qcOk ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back or reset form for next item
      final shouldContinue = await _showSuccessDialog(status);
      
      if (shouldContinue && _currentItemNumber < widget.target.quantity) {
        // Reset form for next item
        _resetFormForNextItem();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _showSuccessDialog(String status) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == AppConstants.qcOk ? 'QC Berhasil!' : 'Barang NG',
          style: TextStyle(
            color: status == AppConstants.qcOk ? Colors.green : Colors.orange,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item #$_currentItemNumber dari ${widget.target.quantity}'),
            Text('Status: $status'),
            if (status == AppConstants.qcNg) ...[
              const SizedBox(height: 8),
              const Text(
                'Barang telah dimasukkan ke daftar NG',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Lanjutkan ke item berikutnya?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Selesai'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Item Berikutnya'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _resetFormForNextItem() {
    // Reset form values
    for (var checkpoint in _checkpoints) {
      switch (checkpoint.type) {
        case CheckpointType.boolean:
          _checkpointValues[checkpoint.checkpointId] = true;
          break;
        case CheckpointType.number:
          _checkpointValues[checkpoint.checkpointId] = checkpoint.minValue ?? 0;
          _textControllers[checkpoint.checkpointId]?.text = 
              (checkpoint.minValue ?? 0).toString();
          break;
        case CheckpointType.text:
          _checkpointValues[checkpoint.checkpointId] = '';
          _textControllers[checkpoint.checkpointId]?.text = '';
          break;
      }
    }
    
    _photoPaths.clear();
    _photoBytes.clear();
    _notes = '';
    _showNGPhotos = false;
    _currentItemNumber++;
    
    setState(() {});
  }

  Widget _buildCheckpointItem(Checkpoint checkpoint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    checkpoint.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (checkpoint.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'WAJIB',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (checkpoint.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                checkpoint.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Checkpoint input based on type
            _buildCheckpointInput(checkpoint),
            
            // Validation info for number type
            if (checkpoint.type == CheckpointType.number &&
                (checkpoint.minValue != null || checkpoint.maxValue != null))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Range: ${checkpoint.minValue ?? ''} - ${checkpoint.maxValue ?? ''} ${checkpoint.unit ?? ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckpointInput(Checkpoint checkpoint) {
    final currentValue = _checkpointValues[checkpoint.checkpointId];
    
    switch (checkpoint.type) {
      case CheckpointType.boolean:
        return Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('OK'),
                selected: currentValue == true,
                onSelected: (selected) {
                  setState(() {
                    _checkpointValues[checkpoint.checkpointId] = true;
                  });
                },
                selectedColor: Colors.green[100],
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: currentValue == true ? Colors.green : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('NG'),
                selected: currentValue == false,
                onSelected: (selected) {
                  setState(() {
                    _checkpointValues[checkpoint.checkpointId] = false;
                    if (selected) {
                      _showNGPhotos = true;
                    }
                  });
                },
                selectedColor: Colors.orange[100],
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: currentValue == false ? Colors.orange : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
        
      case CheckpointType.number:
        return TextFormField(
          controller: _textControllers[checkpoint.checkpointId],
          decoration: InputDecoration(
            labelText: 'Nilai (${checkpoint.unit ?? ''})',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: checkpoint.unit != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      checkpoint.unit!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : null,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final numValue = double.tryParse(value);
            if (numValue != null) {
              setState(() {
                _checkpointValues[checkpoint.checkpointId] = numValue;
              });
            }
          },
          validator: (value) {
            if (checkpoint.isRequired && (value == null || value.isEmpty)) {
              return 'Harus diisi';
            }
            if (value != null && value.isNotEmpty) {
              final numValue = double.tryParse(value);
              if (numValue == null) {
                return 'Harus berupa angka';
              }
              if (checkpoint.minValue != null && numValue < checkpoint.minValue!) {
                return 'Minimal ${checkpoint.minValue}';
              }
              if (checkpoint.maxValue != null && numValue > checkpoint.maxValue!) {
                return 'Maksimal ${checkpoint.maxValue}';
              }
            }
            return null;
          },
        );
        
      case CheckpointType.text:
        return TextFormField(
          controller: _textControllers[checkpoint.checkpointId],
          decoration: InputDecoration(
            labelText: 'Isian',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _checkpointValues[checkpoint.checkpointId] = value;
            });
          },
          validator: (value) {
            if (checkpoint.isRequired && (value == null || value.isEmpty)) {
              return 'Harus diisi';
            }
            return null;
          },
        );
    }
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Barang NG',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Foto wajib diambil untuk barang dengan status NG',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        
        // Photo Grid
        if (_photoPaths.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _photoPaths.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.memory(
                              _photoBytes[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.file(
                              File(_photoPaths[index]),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        
        const SizedBox(height: 16),
        
        // Photo Buttons
        Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.photo_library),
        label: const Text('Pilih dari Galeri'),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: OutlinedButton.icon(
        onPressed: _takePhoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Ambil Foto'),
      ),
    ),
    const SizedBox(width: 8),
    IconButton(
      onPressed: _openPhotoCapture,
      icon: const Icon(Icons.camera_enhance),
      tooltip: 'Mode Foto Lengkap',
    ),
  ],
),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QC Form'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat checklist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadCheckpoints,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form QC'),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target Info Card
                Card(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.target.productName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                'Item #$_currentItemNumber/${widget.target.quantity}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kategori: ${widget.target.category}',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Customer: ${widget.target.customer}',
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (widget.target.currentProgress + 1) /
                              widget.target.quantity,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress: ${widget.target.currentProgress + 1}/${widget.target.quantity}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${((widget.target.currentProgress + 1) / widget.target.quantity * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Checkpoints
                const Text(
                  'Checklist QC',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_checkpoints.length} checkpoint ditemukan',
                  style: const TextStyle(color: Colors.grey),
                ),
                
                const SizedBox(height: 16),
                
                // Checkpoint List
                ..._checkpoints.map(_buildCheckpointItem).toList(),
                
                // NG Photos Section (shown when any checkpoint is NG or manually shown)
                if (_showNGPhotos || _checkpointValues.values.any((v) => v == false))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _buildPhotoSection(),
                  ),
                
                // Notes
                const SizedBox(height: 16),
                const Text(
                  'Catatan Tambahan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  onChanged: (value) => _notes = value,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan jika diperlukan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                // Submit Button
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitQC,
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: Text(
                      _isSubmitting ? 'Menyimpan...' : 'SIMPAN QC',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          if (_isSubmitting)
            const LoadingOverlay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all text controllers
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}