// lib/screens/pic/qc_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:monitoringng2/providers/auth_provider.dart';
import 'package:monitoringng2/services/qc_service.dart';
import 'package:monitoringng2/models/qc_record_model.dart';
import 'package:monitoringng2/utils/constants.dart';
class QCHistoryScreen extends StatefulWidget {
  const QCHistoryScreen({super.key});

  @override
  State<QCHistoryScreen> createState() => _QCHistoryScreenState();
}

class _QCHistoryScreenState extends State<QCHistoryScreen> {
  final QCService _qcService = QCService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');
  
  List<QCRecord> _qcRecords = [];
  List<QCRecord> _filteredRecords = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'all';
  DateTime? _selectedDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadQCHistory();
  }

  Future<void> _loadQCHistory() async {
    try {
      setState(() => _isLoading = true);
      
      final authProvider = context.read<AuthProvider>();
      final picId = authProvider.user?.userId ?? '';
      
      // Get QC records for this PIC
      final snapshot = await _qcService.getQCRecordsByPIC(picId).first;
      
      setState(() {
        _qcRecords = snapshot;
        _filteredRecords = snapshot;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<QCRecord> filtered = _qcRecords;

    // Apply status filter
    if (_filterStatus != 'all') {
      filtered = filtered.where((record) => record.status == _filterStatus).toList();
    }

    // Apply date filter
    if (_selectedDate != null) {
      filtered = filtered.where((record) {
        return _dateFormat.format(record.qcTimestamp) == 
               _dateFormat.format(_selectedDate!);
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((record) {
        return record.productName.toLowerCase().contains(query) ||
               record.category.toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredRecords = filtered);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _applyFilters();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _applyFilters();
    });
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Cari produk atau kategori...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Semua Status'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.qcOk,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('OK'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.qcNg,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('NG'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value!;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Date Filter
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? _dateFormat.format(_selectedDate!)
                              : 'Semua Tanggal',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _clearDateFilter,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQCItem(QCRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: record.isOk ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: record.isOk ? Colors.green : Colors.orange,
              width: 2,
            ),
          ),
          child: Icon(
            record.isOk ? Icons.check_circle : Icons.warning,
            color: record.isOk ? Colors.green : Colors.orange,
            size: 24,
          ),
        ),
        title: Text(
          record.productName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Kategori: ${record.category}'),
            Text(
              '${_dateFormat.format(record.qcTimestamp)} • ${_timeFormat.format(record.qcTimestamp)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    record.isOk ? 'OK' : 'NG',
                    style: TextStyle(
                      color: record.isOk ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: record.isOk ? Colors.green[50] : Colors.orange[50],
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    '${record.passedCheckpoints}/${record.totalCheckpoints}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showQCDetails(record),
      ),
    );
  }

  void _showQCDetails(QCRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: record.isOk ? Colors.green[50] : Colors.orange[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: record.isOk ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      record.isOk ? Icons.check : Icons.warning,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.productName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          record.category,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // QC Info
                    _buildDetailItem('Status', record.status),
                    _buildDetailItem('Waktu QC', formatDateTime(record.qcTimestamp)),
                    _buildDetailItem(
                      'Checkpoint',
                      '${record.passedCheckpoints}/${record.totalCheckpoints}',
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Checkpoint Results
                    const Text(
                      'Hasil Checkpoint:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...record.checkpointResults.entries.map((entry) {
                      final checkpointId = entry.key;
                      final result = entry.value;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: result.isPass ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: result.isPass ? Colors.green : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              result.isPass ? Icons.check_circle : Icons.cancel,
                              color: result.isPass ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    checkpointId.replaceAll('_', ' ').toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Nilai: ${_formatCheckpointValue(result.value)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (result.min != null && result.max != null)
                                    Text(
                                      'Range: ${result.min} - ${result.max}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    // Notes
                    if (record.notes != null && record.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Catatan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(record.notes!),
                    ],
                    
                    // Photos (if NG)
                    if (record.isNg && record.photoUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Foto Barang NG:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: record.photoUrls.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showPhotoDialog(record.photoUrls[index]),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(record.photoUrls[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCheckpointValue(dynamic value) {
    if (value == null) return '-';
    if (value is bool) return value ? 'OK' : 'NG';
    return value.toString();
  }

  void _showPhotoDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final totalQC = _qcRecords.length;
    final okQC = _qcRecords.where((r) => r.isOk).length;
    final ngQC = _qcRecords.where((r) => r.isNg).length;
    final successRate = totalQC > 0 ? (okQC / totalQC * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total QC', totalQC.toString(), Icons.list),
          _buildStatItem('OK', okQC.toString(), Icons.check_circle, Colors.green),
          _buildStatItem('NG', ngQC.toString(), Icons.warning, Colors.orange),
          _buildStatItem(
            'Success Rate', 
            '${successRate.toStringAsFixed(1)}%', 
            Icons.trending_up, 
            Colors.blue
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: (color ?? Colors.blue).withOpacity(0.1),
          child: Icon(icon, color: color ?? Colors.blue, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat QC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQCHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats
          _buildStats(),
          
          // Filters
          _buildFilterBar(),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadQCHistory,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _filteredRecords.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, size: 80, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada riwayat QC',
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Mulai melakukan QC untuk melihat riwayat',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredRecords.length,
                            itemBuilder: (context, index) {
                              return _buildQCItem(_filteredRecords[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}