import 'package:flutter/material.dart';

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
  // Data Pekerjaan PIC (Kosong karena akan diisi dari API/backend)
  final Map<String, List<Map<String, dynamic>>> _categoryProducts = {
    'Body Parts': [],
  };

  @override
  Widget build(BuildContext context) {
    final products = _categoryProducts[widget.category] ?? [];
    
    // Sortir: Urgent/Prioritas paling atas
    products.sort((a, b) {
      if (a['isUrgent'] && !b['isUrgent']) return -1;
      if (!a['isUrgent'] && b['isUrgent']) return 1;
      return (a['completed'] / a['dailyTarget']).compareTo(b['completed'] / b['dailyTarget']);
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
                double progress = product['completed'] / product['dailyTarget'];
                bool isUrgent = product['isUrgent'];

                return Card(
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
                            Expanded(child: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            if (isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(4)),
                                child: const Text('PRIORITAS', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        Text('Customer: ${product['customer']}', style: const TextStyle(color: Colors.grey)),
                        
                        const SizedBox(height: 12),
                        
                        LinearProgressIndicator(
                          value: progress,
                          color: progress >= 1.0 ? Colors.green : (isUrgent ? Colors.red : Colors.blue),
                          backgroundColor: Colors.grey[200],
                          minHeight: 8,
                        ),
                        const SizedBox(height: 6),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${(progress * 100).toInt()}% Selesai', style: const TextStyle(fontSize: 12)),
                            Text('${product['completed']} / ${product['dailyTarget']} pcs', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
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
    // Kirim dengan tipe yang benar untuk menghindari error
    Navigator.pushNamed(
      context,
      '/quality-check',
      arguments: {
        'product': <String, dynamic>{}, // Map kosong dengan tipe yang eksplisit
        'picId': widget.picId,
      },
    );
  }
}