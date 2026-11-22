import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/kategori_provider.dart';
import '../providers/preferensi_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/dialogs.dart';
import 'auth_screen.dart';
import 'kategori_list_screen.dart';

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  void _bantuan(BuildContext context) {
    Widget faq(String tanya, String jawab) => ExpansionTile(
          tilePadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(tanya, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          expandedAlignment: Alignment.centerLeft,
          children: [Text(jawab, style: const TextStyle(fontSize: 13, height: 1.4))],
        );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const Text('Pusat Bantuan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              faq(
                'Bagaimana cara mencatat resi?',
                'Tekan tombol + di tengah, lalu pilih scan struk, galeri/resi digital, atau input manual. '
                    'Periksa hasilnya, lalu tekan Simpan.',
              ),
              faq(
                'Kenapa ada item "Lain-lain"?',
                'Item yang tidak dikenali konteksnya otomatis masuk ke kategori Lain-lain. '
                    'Kamu bisa mengubah kategorinya di form sebelum menyimpan.',
              ),
              faq(
                'Bagaimana mengubah atau menghapus resi?',
                'Buka resi dari daftar, lalu gunakan ikon pensil untuk mengubah atau ikon tempat sampah untuk menghapus.',
              ),
              faq(
                'Apa itu Monthly Wrapped?',
                'Ringkasan interaktif pengeluaran bulananmu, lengkap dengan perbandingan terhadap bulan sebelumnya. '
                    'Buka dari Beranda atau tab Statistik.',
              ),
              faq(
                'Apakah data resi saya tersimpan?',
                'Ya. Resi dan kategori tersimpan otomatis di akun BonKu-mu, jadi tidak hilang saat aplikasi ditutup. '
                    'Masuk dengan akun yang sama untuk melihat datamu lagi.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tentang(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BonKu',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.receipt_long_rounded,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
      applicationLegalese: '© 2026 JD Team • Pemrograman Mobile USU',
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('BonKu membantu mencatat pengeluaran otomatis dari struk fisik dan resi digital.'),
        ),
      ],
    );
  }

  Future<void> _keluar(BuildContext context) async {
    final ya = await konfirmasiHapus(
      context,
      judul: 'Keluar dari akun?',
      pesan: 'Kamu perlu masuk lagi untuk memakai BonKu.',
      labelHapus: 'Keluar',
    );
    if (!ya || !context.mounted) return;
    await context.read<AuthProvider>().keluar();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  Future<void> _kosongkan(BuildContext context) async {
    final trx = context.read<TransaksiProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final jumlah = trx.items.length;

    if (jumlah == 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Tidak ada resi untuk dihapus.')));
      return;
    }
    final ya = await konfirmasiHapus(
      context,
      judul: 'Kosongkan semua resi?',
      pesan: '$jumlah resi akan dihapus. Data awal bisa dipulihkan dari menu ini.',
      labelHapus: 'Kosongkan',
    );
    if (!ya) return;

    final ok = await trx.kosongkan();
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? 'Semua resi dihapus.' : (trx.errorMessage ?? 'Gagal menghapus.'))),
    );
  }

  Future<void> _pulihkan(BuildContext context) async {
    final trx = context.read<TransaksiProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await trx.pulihkan();
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? 'Data awal dipulihkan.' : (trx.errorMessage ?? 'Gagal memulihkan.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final pref = context.watch<PreferensiProvider>();
    final trx = context.watch<TransaksiProvider>();
    final scan = context.watch<ScanProvider>();
    final kategori = context.read<KategoriProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSectionTitle(theme, 'Preferensi'),
          _buildSettingItem(
            theme,
            icon: Icons.dark_mode_rounded,
            title: 'Tema Tampilan',
            subtitle: themeProvider.isDarkMode ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
          _buildSettingItem(
            theme,
            icon: Icons.notifications_active_rounded,
            title: 'Pengingat Pencatatan',
            subtitle: pref.pengingatAktif ? 'Aktif • ${pref.jadwalTeks}' : 'Nonaktif',
            trailing: Switch(
              value: pref.pengingatAktif,
              onChanged: (val) {
                pref.setPengingat(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(val ? 'Pengingat diaktifkan' : 'Pengingat dimatikan')),
                );
              },
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
          _buildSettingItem(
            theme,
            icon: Icons.schedule_rounded,
            title: 'Jadwal Pengingat',
            subtitle: pref.pengingatAktif ? pref.jadwalTeks : 'Aktifkan pengingat terlebih dulu',
            onTap: pref.pengingatAktif
                ? () => showDialog<void>(context: context, builder: (_) => const _JadwalDialog())
                : null,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'Keamanan & Data'),
          _buildSettingItem(
            theme,
            icon: Icons.category_rounded,
            title: 'Kelola Kategori',
            subtitle: 'Tambah, ubah, dan hapus kategori pengeluaran',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KategoriListScreen()),
            ),
          ),
          _buildSettingItem(
            theme,
            icon: Icons.security_rounded,
            title: 'Privasi & Keamanan',
            subtitle: 'Cara data disimpan dan diproses',
            onTap: () => tampilkanInfo(
              context,
              judul: 'Privasi & Keamanan',
              pesan: 'Resi dan kategori disimpan di akun BonKu-mu menggunakan Google Firebase (Cloud Firestore). '
                  'Gambar struk hanya disimpan sebagai path, bukan file utuh. '
                  'Saat scan, foto struk dikirim ke layanan Google Gemini untuk dibaca.',
            ),
          ),
          _buildSettingItem(
            theme,
            icon: Icons.cloud_done_rounded,
            title: 'Penyimpanan Data',
            subtitle: 'Tersimpan otomatis di akun BonKu-mu',
          ),
          if (pref.modeDemo) ...[
            const SizedBox(height: 24),
            _buildSectionTitle(theme, 'Mode Demo'),
            _buildSettingItem(
              theme,
              icon: Icons.bug_report_rounded,
              title: 'Simulasi Gagal',
              subtitle: 'Paksa pemuatan dan penyimpanan data gagal',
              trailing: Switch(
                value: trx.simulasiGagal,
                onChanged: (val) {
                  trx.simulasiGagal = val;
                  kategori.simulasiGagal = val;
                  trx.muat();
                  kategori.muat();
                },
                activeThumbColor: theme.colorScheme.primary,
              ),
            ),
            _buildSettingItem(
              theme,
              icon: Icons.auto_awesome_rounded,
              title: 'Pemindai Simulasi',
              subtitle: 'Hasil scan contoh tanpa memakai kuota Gemini',
              trailing: Switch(
                value: scan.pakaiSimulasi,
                onChanged: scan.setPakaiSimulasi,
                activeThumbColor: theme.colorScheme.primary,
              ),
            ),
            _buildSettingItem(
              theme,
              icon: Icons.delete_sweep_rounded,
              title: 'Kosongkan Semua Resi',
              subtitle: 'Hapus semua resi di akun ini (uji tampilan kosong)',
              iconColor: colorScheme.error,
              onTap: trx.isSubmitting ? null : () => _kosongkan(context),
            ),
            _buildSettingItem(
              theme,
              icon: Icons.restore_rounded,
              title: 'Pulihkan Data Awal',
              subtitle: 'Kembalikan 24 resi contoh',
              onTap: trx.isSubmitting ? null : () => _pulihkan(context),
            ),
          ],
          const SizedBox(height: 24),
          _buildSectionTitle(theme, 'Lainnya'),
          _buildSettingItem(
            theme,
            icon: Icons.help_outline_rounded,
            title: 'Pusat Bantuan',
            subtitle: 'Panduan scan & keluhan',
            onTap: () => _bantuan(context),
          ),
          _buildSettingItem(
            theme,
            icon: Icons.info_outline_rounded,
            title: 'Tentang BonKu',
            subtitle: 'Versi 1.0.0',
            onTap: () => _tentang(context),
          ),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
          const SizedBox(height: 16),
          const _VersiAplikasi(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final warna = iconColor ?? theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: warna, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          trailing: trailing ??
              (onTap == null
                  ? null
                  : Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _keluar(context),
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              'Keluar Akun',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JadwalDialog extends StatefulWidget {
  const _JadwalDialog();

  @override
  State<_JadwalDialog> createState() => _JadwalDialogState();
}

class _JadwalDialogState extends State<_JadwalDialog> {
  late FrekuensiPengingat _frekuensi;
  late TimeOfDay _jam;

  @override
  void initState() {
    super.initState();
    final pref = context.read<PreferensiProvider>();
    _frekuensi = pref.frekuensi;
    _jam = pref.jam;
  }

  String get _jamTeks =>
      '${_jam.hour.toString().padLeft(2, '0')}:${_jam.minute.toString().padLeft(2, '0')}';

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(context: context, initialTime: _jam);
    if (hasil != null) setState(() => _jam = hasil);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Jadwal Pengingat'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<FrekuensiPengingat>(
            segments: const [
              ButtonSegment(value: FrekuensiPengingat.harian, label: Text('Harian')),
              ButtonSegment(value: FrekuensiPengingat.bulanan, label: Text('Bulanan')),
            ],
            selected: {_frekuensi},
            onSelectionChanged: (s) => setState(() => _frekuensi = s.first),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time_rounded),
            title: const Text('Pukul'),
            trailing: Text(_jamTeks, style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: _pilihJam,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            context.read<PreferensiProvider>().setJadwal(_frekuensi, _jam);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Jadwal pengingat diperbarui.')),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _VersiAplikasi extends StatefulWidget {
  const _VersiAplikasi();

  @override
  State<_VersiAplikasi> createState() => _VersiAplikasiState();
}

class _VersiAplikasiState extends State<_VersiAplikasi> {
  static const _target = 7;
  static const _jeda = Duration(seconds: 2);

  int _ketukan = 0;
  DateTime? _terakhir;

  void _ketuk() {
    final sekarang = DateTime.now();
    if (_terakhir != null && sekarang.difference(_terakhir!) > _jeda) {
      _ketukan = 0;
    }
    _terakhir = sekarang;
    _ketukan++;

    final pref = context.read<PreferensiProvider>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (_ketukan >= _target) {
      _ketukan = 0;
      final aktif = !pref.modeDemo;
      pref.setModeDemo(aktif);
      if (!aktif) _matikanSimulasi();
      messenger.showSnackBar(
        SnackBar(content: Text(aktif ? 'Mode Demo diaktifkan.' : 'Mode Demo dinonaktifkan.')),
      );
    } else if (_ketukan >= 4) {
      final sisa = _target - _ketukan;
      final aksi = pref.modeDemo ? 'menonaktifkan' : 'mengaktifkan';
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Tinggal $sisa ketukan lagi untuk $aksi Mode Demo.'),
        ),
      );
    }
  }

  void _matikanSimulasi() {
    final trx = context.read<TransaksiProvider>();
    final kategori = context.read<KategoriProvider>();
    final perluMuatUlang = trx.simulasiGagal || kategori.simulasiGagal;
    trx.simulasiGagal = false;
    kategori.simulasiGagal = false;
    context.read<ScanProvider>().setPakaiSimulasi(false);
    if (perluMuatUlang) {
      trx.muat();
      kategori.muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: InkWell(
        onTap: _ketuk,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('BonKu v1.0.0', style: TextStyle(fontSize: 12, color: warna)),
        ),
      ),
    );
  }
}