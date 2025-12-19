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
  final Map<String, bool> _hasPhotoEvidence = {}; 
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi hasil check
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
    }
    return 'boolean'; 
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
            // INFO PRODUKSI (Pengganti Batch)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Customer', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(widget.product['customer'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Target Hari Ini', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('${widget.product['dailyTarget']} pcs', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text('ITEM PEMERIKSAAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            // List Pengecekan
            ...widget.product['qualityItems'].map<Widget>((item) {
              return _buildCheckItem(item['name'], item['standard']);
            }).toList(),
            
            const SizedBox(height: 24),
    
            // Tombol Simpan
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

  Widget _buildCheckItem(String itemName, String standardValue) {
    final result = _checkResults[itemName];
    final type = result?['type'] ?? 'text';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                  child: Text('Std: $standardValue', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (type == 'numeric') 
               _buildNumericInput(itemName),
            
            const SizedBox(height: 12),
            _buildStatusToggle(itemName),
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

  Widget _buildStatusToggle(String itemName) {
    final result = _checkResults[itemName];
    final bool isPassed = result?['passed'] ?? true;
    final bool hasPhoto = _hasPhotoEvidence[itemName] ?? false;

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
        
        // Logika Wajib Foto Jika NG
        if (!isPassed) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text('Bukti Foto Wajib Diisi!', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _hasPhotoEvidence[itemName] = true);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto bukti tersimpan')));
                    },
                    icon: Icon(hasPhoto ? Icons.check_circle : Icons.camera_alt, size: 16),
                    label: Text(hasPhoto ? 'Foto Terlampir' : 'Ambil Foto Cacat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasPhoto ? Colors.green : Colors.red,
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

  void _submitCheck() async {
    // Validasi
    for (var entry in _checkResults.entries) {
      if (entry.value['type'] == 'numeric' && (entry.value['value'] == null || entry.value['value'].toString().isEmpty)) {
        _showError('Isi nilai aktual untuk ${entry.key}');
        return;
      }
      
      if (entry.value['passed'] == false && _hasPhotoEvidence[entry.key] != true) {
         _showError('Wajib foto bukti NG untuk: ${entry.key}');
         return;
      }
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2)); 
    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data Quality Check Berhasil Disimpan'), backgroundColor: Colors.green),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}