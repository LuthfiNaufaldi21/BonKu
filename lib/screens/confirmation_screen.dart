import 'package:flutter/material.dart';

class ConfirmationScreen extends StatefulWidget {
  // Nantinya imagePath dan initialItems akan dikirim dari layar sebelumnya (Kamera/Share)
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  // Data dummy meniru hasil kembalian dari Gemini API (FR-03 & FR-04)
  final List<Map<String, dynamic>> _scannedItems = [
    {
      'name': 'Nasi Goreng Spesial',
      'category': 'Konsumsi',
      'price': 25000,
    },
    {
      'name': 'Buku Tulis Sinar Dunia',
      'category': 'Edukasi',
      'price': 15000,
    },
    {
      'name': 'Barang Tidak Jelas AAA',
      'category': 'Lain-lain / Belum Dikategorikan', // Sesuai FR-03
      'price': 50000,
    }
  ];

  final List<String> _categories = [
    'Konsumsi',
    'Transportasi',
    'Edukasi',
    'Kesehatan',
    'Hiburan',
    'Lain-lain / Belum Dikategorikan'
  ];

  int get _calculateTotal {
    return _scannedItems.fold(0, (sum, item) => sum + (item['price'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validasi Struk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Bagian Atas: Preview Gambar Struk (NFR-02: hanya menampilkan dari Path)
          Container(
            height: 150,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 50, color: Colors.grey),
                  Text('Preview Struk Fisik/Digital', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Daftar Item yang diekstrak
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _scannedItems.length,
              itemBuilder: (context, index) {
                final item = _scannedItems[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        // Edit Nama Barang
                        TextFormField(
                          initialValue: item['name'],
                          decoration: const InputDecoration(
                            labelText: 'Nama Barang',
                            border: UnderlineInputBorder(),
                          ),
                          onChanged: (value) => item['name'] = value,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Ubah Kategori
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: item['category'],
                                decoration: const InputDecoration(
                                  labelText: 'Kategori',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                                isExpanded: true,
                                items: _categories.map((String category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    item['category'] = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Edit Harga
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: item['price'].toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Harga (Rp)',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    item['price'] = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Tombol Simpan (Bagian Bawah)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pengeluaran', style: TextStyle(fontSize: 12)),
                  Text(
                    'Rp $_calculateTotal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Hubungkan dengan fungsi insert SQLite terenkripsi (NFR-03)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil disimpan!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}