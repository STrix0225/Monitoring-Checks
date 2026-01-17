// lib/screens/head/ng_items_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monitoringng2/providers/ng_item_provider.dart';
import 'package:monitoringng2/providers/auth_provider.dart';
import 'package:monitoringng2/models/ng_item_model.dart';
import 'package:monitoringng2/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitoringng2/utils/constants.dart';

class NGItemsScreen extends StatefulWidget {
  const NGItemsScreen({super.key});

  @override
  State<NGItemsScreen> createState() => _NGItemsScreenState();
}

class _NGItemsScreenState extends State<NGItemsScreen> {
  final TextEditingController _meltLocationController = TextEditingController();
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _meltLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(),
          // Content
          Expanded(
            child: _buildNGItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterStatus,
              decoration: InputDecoration(
                labelText: 'Filter Status',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, size: 16),
                      const SizedBox(width: 8),
                      const Text('Semua Status'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'pending',
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
                      const Text('Pending'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'confirmed_for_melt',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Konfirmasi Peleburan'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              Provider.of<NGItemProvider>(context, listen: false)
                  .loadPendingItems();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNGItemsList() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(AppConstants.ngItemsCollection)
              .orderBy('ngTimestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final allItems = snapshot.data?.docs.map((doc) {
                  return NGItem.fromFirestore(doc);
                }).toList() ?? [];

            List<NGItem> filteredItems = allItems;
            if (_filterStatus != 'all') {
              filteredItems = allItems
                  .where((item) => item.status == _filterStatus)
                  .toList();
            }

            if (filteredItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada barang NG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Semua barang lolos QC',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildNGItemCard(item);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNGItemCard(NGItem item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showNGItemDetail(item),
        borderRadius: BorderRadius.circular(8),
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
                      item.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(item.status),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Kategori: ${item.category}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dilaporkan: ${item.picName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDateTime(item.ngTimestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              if (item.isPending) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.check_circle, size: 18, color: Colors.blue),
                    label: const Text('Konfirmasi Peleburan'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      side: const BorderSide(color: Colors.blue),
                    ),
                    onPressed: () => _confirmItem(item),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed_for_melt':
        return Colors.blue;
      case 'melted':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'confirmed_for_melt':
        return 'KONFIRMASI';
      case 'melted':
        return 'PELEBURAN';
      default:
        return status.toUpperCase();
    }
  }

  Future<void> _confirmItem(NGItem item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ngProvider = Provider.of<NGItemProvider>(context, listen: false);

    final confirmedBy = auth.user?.name ?? 'unknown';

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Barang NG'),
        content: Text(
          'Apakah Anda yakin ingin mengkonfirmasi barang "${item.productName}" untuk dilebur?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    try {
      await ngProvider.confirmForMelt(item.ngId, confirmedBy);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status berhasil diubah ke KONFIRMASI.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengkonfirmasi: $e')),
        );
      }
    }
  }

  void _showNGItemDetail(NGItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Barang NG'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Nama Produk', item.productName),
              _buildDetailSection('Kategori', item.category),
              _buildDetailSection('Alasan NG', item.reason),
              if (item.failedPoints.isNotEmpty)
                _buildDetailSection(
                  'Poin yang Gagal',
                  item.failedPoints.map((p) => '• $p').join('\n'),
                ),
              _buildDetailSection('Dilaporkan oleh', item.picName),
              _buildDetailSection('Waktu', formatDateTime(item.ngTimestamp)),
              _buildDetailSection('Status', _getStatusLabel(item.status)),
              if (item.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Foto Bukti:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: item.photoUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showImageDialog(item.photoUrls[index]);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.photoUrls[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Foto Bukti'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ],
        ),
      ),
    );
  }
}