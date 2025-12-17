import 'package:flutter/material.dart';

class QualityCheckScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String picId;

  const QualityCheckScreen({
    super.key,
    required this.product,
    required this.picId,
  });

  @override
  State<QualityCheckScreen> createState() => _QualityCheckScreenState();
}

class _QualityCheckScreenState extends State<QualityCheckScreen> {
  final Map<String, dynamic> _checkResults = {};
  bool _isSubmitting = false;
  String? _selectedBatch;

  final List<String> _batchNumbers = [
    'BATCH-001-2024',
    'BATCH-002-2024',
    'BATCH-003-2024',
    'BATCH-004-2024',
  ];
  
  @override
  void initState() {
    super.initState();
    _selectedBatch = _batchNumbers.first;
    for (var item in widget.product['qualityItems']) {
      _checkResults[item['name']] = {
        'value': '',
        'passed': true,
        'type': _determineItemType(item['name']),
      };
    }
  }
  
  String _determineItemType(String itemName) {
    if (itemName.toLowerCase().contains('ketebalan') || 
        itemName.toLowerCase().contains('diameter') ||
        itemName.toLowerCase().contains('panjang') ||
        itemName.toLowerCase().contains('sudut')) {
      return 'numeric';
    } else if (itemName.toLowerCase().contains('ada') ||
               itemName.toLowerCase().contains('tidak')) {
      return 'boolean';
    } else {
      return 'text';
    }
  }

  Widget _buildCheckItem(String itemName, String standardValue) {
    final result = _checkResults[itemName];
    final type = result?['type'] ?? 'text';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Standard: $standardValue',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (type == 'boolean') _buildBooleanInput(itemName),
            if (type == 'numeric') _buildNumericInput(itemName, standardValue),
            if (type == 'text') _buildTextInput(itemName),
            
            const SizedBox(height: 12),
            _buildStatusToggle(itemName),
          ],
        ),
      ),
    );
  }

  Widget _buildBooleanInput(String itemName) {
    final result = _checkResults[itemName];
    final bool isYes = result?['value'] == 'Ya';
    final bool isNo = result?['value'] == 'Tidak';

    return Column(
      children: [
        const Text(
          'Status:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _checkResults[itemName] = {
                      ..._checkResults[itemName]!,
                      'value': 'Ya',
                      'passed': true,
                    };
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isYes ? Colors.green[50] : null,
                  side: BorderSide(
                    color: isYes ? Colors.green : Colors.grey[300]!,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Ya',
                  style: TextStyle(
                    fontSize: 12,
                    color: isYes ? Colors.green : Colors.grey[600],
                    fontWeight: isYes ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _checkResults[itemName] = {
                      ..._checkResults[itemName]!,
                      'value': 'Tidak',
                      'passed': false,
                    };
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isNo ? Colors.red[50] : null,
                  side: BorderSide(
                    color: isNo ? Colors.red : Colors.grey[300]!,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Tidak',
                  style: TextStyle(
                    fontSize: 12,
                    color: isNo ? Colors.red : Colors.grey[600],
                    fontWeight: isNo ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumericInput(String itemName, String standardValue) {
    final result = _checkResults[itemName];
    final TextEditingController controller = TextEditingController(
      text: result?['value']?.toString() ?? '',
    );
    
    final standardMatch = RegExp(r'[\d.]+').firstMatch(standardValue);
    final double? standardNum = standardMatch != null 
        ? double.tryParse(standardMatch.group(0)!) 
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Masukkan nilai aktual',
            labelStyle: const TextStyle(fontSize: 12),
            suffixText: _getUnit(standardValue),
            suffixStyle: const TextStyle(fontSize: 12),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          onChanged: (value) {
            final numValue = double.tryParse(value);
            final isPassed = numValue != null && standardNum != null 
                ? (itemName.toLowerCase().contains('ketebalan') 
                    ? numValue >= standardNum 
                    : (itemName.toLowerCase().contains('diameter') 
                        ? (numValue - standardNum).abs() <= 0.1
                        : numValue == standardNum))
                : false;
            
            setState(() {
              _checkResults[itemName] = {
                ..._checkResults[itemName]!,
                'value': value,
                'passed': isPassed,
              };
            });
          },
        ),
        const SizedBox(height: 8),
        if (standardNum != null)
          Text(
            'Rentang yang diterima: ${_getToleranceRange(itemName, standardNum)}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  String _getUnit(String standardValue) {
    if (standardValue.contains('mm')) return 'mm';
    if (standardValue.contains('°')) return '°';
    return '';
  }

  String _getToleranceRange(String itemName, double standardNum) {
    if (itemName.toLowerCase().contains('ketebalan')) {
      return '≥ $standardNum mm';
    } else if (itemName.toLowerCase().contains('diameter')) {
      return '$standardNum ± 0.1 mm';
    } else if (itemName.toLowerCase().contains('sudut')) {
      return '$standardNum° ± 0.5°';
    }
    return standardNum.toString();
  }

  Widget _buildTextInput(String itemName) {
    final result = _checkResults[itemName];
    final TextEditingController controller = TextEditingController(
      text: result?['value']?.toString() ?? '',
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan pemeriksaan:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Masukkan catatan...',
            hintStyle: TextStyle(fontSize: 12),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _checkResults[itemName] = {
                ..._checkResults[itemName]!,
                'value': value,
                'passed': value.isNotEmpty,
              };
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatusToggle(String itemName) {
    final result = _checkResults[itemName];
    final bool isPassed = result?['passed'] ?? true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: isPassed ? Colors.green : Colors.grey),
                    const SizedBox(width: 4),
                    const Text('Lulus'),
                  ],
                ),
                selected: isPassed,
                selectedColor: Colors.green[100],
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isPassed ? Colors.green : Colors.grey[600],
                ),
                onSelected: (selected) {
                  setState(() {
                    _checkResults[itemName] = {
                      ..._checkResults[itemName]!,
                      'passed': true,
                    };
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 14, color: !isPassed ? Colors.red : Colors.grey),
                    const SizedBox(width: 4),
                    const Text('Tidak Lulus'),
                  ],
                ),
                selected: !isPassed,
                selectedColor: Colors.red[100],
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: !isPassed ? Colors.red : Colors.grey[600],
                ),
                onSelected: (selected) {
                  setState(() {
                    _checkResults[itemName] = {
                      ..._checkResults[itemName]!,
                      'passed': false,
                    };
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitCheck() async {
    for (var entry in _checkResults.entries) {
      if (entry.value['value'] == null || entry.value['value'].toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silakan isi semua item pemeriksaan untuk ${entry.key}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    int passedCount = 0;
    int failedCount = 0;
    for (var entry in _checkResults.entries) {
      if (entry.value['passed'] == true) {
        passedCount++;
      } else {
        failedCount++;
      }
    }

    final overallStatus = failedCount == 0 ? 'OK' : 'NG';
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              overallStatus == 'OK' ? Icons.check_circle : Icons.error,
              color: overallStatus == 'OK' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              'Quality Check ${overallStatus == 'OK' ? 'Berhasil' : 'Ditemukan Masalah'}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk: ${widget.product['name']}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              'Batch: $_selectedBatch',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: overallStatus == 'OK' ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Total Item',
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        '${_checkResults.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'LULUS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        '$passedCount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'TIDAK LULUS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        '$failedCount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (overallStatus == 'NG')
              Text(
                'Produk akan ditandai sebagai NG dan menunggu konfirmasi kepala departemen.',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Quality check berhasil disimpan (Status: $overallStatus)'),
                  backgroundColor: overallStatus == 'OK' ? Colors.green : Colors.orange,
                ),
              );
            },
            child: const Text(
              'SIMPAN',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quality Check - ${widget.product['name']}',
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${widget.product['id']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'PIC: ${widget.picId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.business, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'PT Pemesan: ${widget.product['ptOrders'].map((o) => o['ptName']).join(', ')}',
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INFORMASI BATCH',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedBatch,
                      items: _batchNumbers.map((batch) {
                        return DropdownMenuItem(
                          value: batch,
                          child: Text(
                            batch,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBatch = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Pilih Nomor Batch',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nomor Seri (Opsional)',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.checklist, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'ITEM PEMERIKSAAN KUALITAS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Periksa semua item berikut sesuai standar kualitas:',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ...widget.product['qualityItems'].map<Widget>((item) {
                      return _buildCheckItem(item['name'], item['standard']);
                    }).toList(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RINGKASAN PEMERIKSAAN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Item Diperiksa:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${_checkResults.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Item Lulus:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${_checkResults.values.where((r) => r['passed'] == true).length}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Item Tidak Lulus:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${_checkResults.values.where((r) => r['passed'] == false).length}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Catatan Tambahan (Opsional)',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan catatan khusus jika diperlukan...',
                        hintStyle: TextStyle(fontSize: 11),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
    
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'SIMPAN QUALITY CHECK',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Panduan Quality Check',
          style: TextStyle(fontSize: 14),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Petunjuk Pengisian:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildHelpItem('1. Pilih batch yang sesuai'),
              _buildHelpItem('2. Isi semua item pemeriksaan'),
              _buildHelpItem('3. Untuk item boolean, pilih "Ya" atau "Tidak"'),
              _buildHelpItem('4. Untuk item numeric, masukkan nilai aktual'),
              _buildHelpItem('5. Sistem akan otomatis mengecek kesesuaian dengan standar'),
              _buildHelpItem('6. Anda bisa mengubah status manual jika diperlukan'),
              _buildHelpItem('7. Jika ada item tidak lulus, produk akan berstatus NG'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Catatan: Produk dengan status NG akan ditinjau ulang oleh kepala departemen sebelum diproses lebih lanjut.',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}