import 'package:flutter/material.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Data dummy untuk daftar notifikasi
    final notifications = [
      {
        'title': 'Waktunya Catat Pengeluaran!',
        'subtitle': 'Belum ada struk yang dicatat hari ini. Yuk scan belanjaanmu agar keuangan tetap terkontrol.',
        'time': 'Hari ini, 20:00',
        'icon': Icons.notifications_active_rounded,
        'color': Colors.orange,
        'isUnread': true,
      },
      {
        'title': 'Monthly Wrapped Siap 🎉',
        'subtitle': 'Evaluasi tren pengeluaran bulan lalu sudah bisa kamu lihat di halaman statistik.',
        'time': 'Kemarin, 09:00',
        'icon': Icons.insights_rounded,
        'color': Colors.deepPurple,
        'isUnread': false,
      },
      {
        'title': 'Peringatan Anggaran Makanan',
        'subtitle': 'Pengeluaran untuk kategori Makanan sudah mencapai 80% dari batas yang kamu tentukan.',
        'time': '28 Sep 2026',
        'icon': Icons.warning_rounded,
        'color': Colors.redAccent,
        'isUnread': false,
      },
      {
        'title': 'Scan Struk Berhasil',
        'subtitle': 'Struk Supermarket senilai -Rp 345.000 berhasil diproses secara otomatis.',
        'time': '27 Sep 2026',
        'icon': Icons.check_circle_rounded,
        'color': Colors.green,
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Aksi tandai semua dibaca
            },
            child: const Text('Tandai Dibaca', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final Color iconColor = notif['color'] as Color;
          final bool isUnread = notif['isUnread'] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Memberikan sedikit perbedaan warna jika pesannya belum dibaca (unread)
              color: isUnread 
                  ? colorScheme.surfaceVariant.withOpacity(0.4) 
                  : colorScheme.surfaceVariant.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnread 
                    ? colorScheme.primary.withOpacity(0.3) 
                    : colorScheme.outlineVariant.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(notif['icon'] as IconData, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Text(
                            notif['time'] as String,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif['subtitle'] as String,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}