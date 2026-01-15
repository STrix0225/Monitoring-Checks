import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../restapi.dart';
import '../../config.dart';
import '../../models/pic_model.dart';
import '../../models/daily_target_model.dart';
import '../../models/product_item_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../head/set_target_screen.dart';
import '../head/pic_detail_screen.dart';
import '../auth/login_screen.dart';

class PicDashboardScreen extends StatefulWidget {
  final String picId;
  final String category;

  const PicDashboardScreen({
    super.key,
    required this.picId,
    required this.category,
  });

  @override
  State<PicDashboardScreen> createState() => _PicDashboardScreenState();

}

class _PicDashboardScreenState extends State<PicDashboardScreen> {
  // Data service + state for PIC dashboard
  final DataService ds = DataService();
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  // Fallback simple category->names mapping (keeps UI when API empty)
  final Map<String, List<String>> _categoryProductsFallback = {
    'Body Parts': [
      'Front pillar upper outer',
      'Cowl assembly',
      'Front pillar',
    ],
    'Interior Parts': [
      'Dash Panel',
      'Seat Frame',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadDailyTargetsForCategory();
  }

  Future<void> _loadDailyTargetsForCategory() async {
    setState(() => _loading = true);
    try {
      final resp = await ds.getDailyTargetsByDate(DateTime.now());
      final api = jsonDecode(resp);
      final List<dynamic> data = api['data'] ?? [];

      final targets = data.map((e) => DailyTargetModel.fromJson(e)).toList();
      final filtered = targets.where((t) => t.category == widget.category).toList();

      _products = filtered.map((t) {
        return {
          'id': t.id,
          'name': t.product,
          'product': t.product,
          'customer': t.customer,
          'dailyTarget': t.targetQty,
          'completed': t.actualQty,
          'isUrgent': false,
          'category': t.category,
        };
      }).toList();
    } catch (e) {
      // keep fallback
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _productsForUI {
    if (_products.isNotEmpty) return _products;
    final names = _categoryProductsFallback[widget.category] ?? [];
    return names.map((name) {
      return {
        'id': '',
        'name': name,
        'product': name,
        'customer': '',
        'dailyTarget': 0,
        'completed': 0,
        'isUrgent': false,
        'category': widget.category,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _productsForUI;

    // Sortir: Urgent/Prioritas paling atas
    products.sort((a, b) {
      final aUrg = a['isUrgent'] == true;
      final bUrg = b['isUrgent'] == true;
      if (aUrg && !bUrg) return -1;
      if (!aUrg && bUrg) return 1;
      final aProg = (a['dailyTarget'] is num && a['dailyTarget'] != 0) ? (a['completed'] / a['dailyTarget']) : 0.0;
      final bProg = (b['dailyTarget'] is num && b['dailyTarget'] != 0) ? (b['completed'] / b['dailyTarget']) : 0.0;
      return aProg.compareTo(bProg);
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard PIC Line'),
            Text(widget.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      // Floating Action Button untuk Quality Check
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startQualityCheck(),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('QC Baru', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info - tanpa tombol "Quality Check"
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(widget.picId, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.category),
              ),
            ),

            const SizedBox(height: 24),

            // List Tugas / Produk (hanya ditampilkan jika ada data)
            if (products.isNotEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.checklist, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('TARGET PRODUKSI HARI INI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
            ],

            Column(
              children: products.map((product) {
                double progress = 0;
                try {
                  final daily = (product['dailyTarget'] is num) ? product['dailyTarget'] as num : 0;
                  final comp = (product['completed'] is num) ? product['completed'] as num : 0;
                  progress = daily > 0 ? (comp / daily).toDouble() : 0.0;
                } catch (_) {
                  progress = 0.0;
                }
                bool isUrgent = product['isUrgent'] == true;

                // CARD TAP: buka detail target (ng-details)
                return InkWell(
                  onTap: () {
                    // Navigasi ke layar detail target (ng-details)
                    // main.dart ng-details route mengharapkan productName : String
                    final productName = product['product'] ?? product['name'] ?? '';
                    Navigator.pushNamed(
                      context,
                      '/ng-details',
                      arguments: productName,
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: isUrgent
                        ? RoundedRectangleBorder(side: const BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(8))
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(product['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                              if (isUrgent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(4)),
                                  child: const Text('PRIORITAS', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          Text('Customer: ${product['customer'] ?? '-'}', style: const TextStyle(color: Colors.grey)),

                          const SizedBox(height: 12),

                          LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            color: progress >= 1.0 ? Colors.green : (isUrgent ? Colors.red : Colors.blue),
                            backgroundColor: Colors.grey[200],
                            minHeight: 8,
                          ),
                          const SizedBox(height: 6),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${(progress * 100).toInt()}% Selesai', style: const TextStyle(fontSize: 12)),
                              Text('${product['completed'] ?? 0} / ${product['dailyTarget'] ?? 0} pcs', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Tampilan ketika tidak ada data
            if (products.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada target produksi hari ini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan hubungi supervisor untuk informasi lebih lanjut',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startQualityCheck() {
    final products = _productsForUI;

    if (products.isEmpty) {
      // Tidak ada produk: beri tahu user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada produk. Pilih atau tambahkan produk sebelum membuat QC.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Jika hanya 1 produk, langsung buka QC untuk produk tersebut
    if (products.length == 1) {
      Navigator.pushNamed(
        context,
        '/quality-check',
        arguments: {
          'product': products.first,
          'target': products.first,
          'picId': widget.picId,
        },
      );
      return;
    }

    // Jika ada lebih dari satu produk, tampilkan pilihan (bottom sheet)
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Pilih produk untuk Quality Check', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...products.map((product) {
                return ListTile(
                  title: Text(product['name'] ?? 'Unnamed product'),
                  subtitle: Text(product['customer'] ?? ''),
                    onTap: () {
                    Navigator.pop(context); // tutup bottom sheet
                    Navigator.pushNamed(
                      context,
                      '/quality-check',
                      arguments: {
                        'product': product,
                        'target': product,
                        'picId': widget.picId,
                      },
                    );
                  },
                );
              }).toList(),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}