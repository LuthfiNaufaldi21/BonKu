import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../models/item_transaksi.dart';
import '../models/transaksi.dart';
import '../providers/kategori_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../widgets/state_views.dart';

class _ItemForm {
  _ItemForm({this.id, String nama = '', String? kategoriId, int? harga})
      : namaC = TextEditingController(text: nama),
        hargaC = TextEditingController(text: harga?.toString() ?? ''),
        key = UniqueKey() {
    this.kategoriId = kategoriId;
  }

  final String? id; 
  final Key key;
  final TextEditingController namaC;
  final TextEditingController hargaC;
  String? kategoriId;

  int get harga => int.tryParse(hargaC.text) ?? 0;

  void dispose() {
    namaC.dispose();
    hargaC.dispose();
  }
}

class ConfirmationScreen extends StatefulWidget {
  final Transaksi? transaksi;
  final SumberResi sumber;

  const ConfirmationScreen({
    super.key,
    this.transaksi,
    this.sumber = SumberResi.kamera,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  static const _maksHarga = 100000000;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokoC;
  late final TextEditingController _catatanC;
  late final TextEditingController _tanggalC;
  late final TextEditingController _jamC;
  late DateTime _tanggal;
  late SumberResi _sumber;
  final List<_ItemForm> _items = [];

  bool get _edit => widget.transaksi != null;
  bool get _hasilScan => !_edit && _sumber != SumberResi.manual;

  @override
  void initState() {
    super.initState();
    final t = widget.transaksi;
    _sumber = t?.sumber ?? widget.sumber;
    _tanggal = t?.tanggal ?? DateTime.now();
    _tokoC = TextEditingController(text: t?.toko ?? '');
    _catatanC = TextEditingController(text: t?.catatan ?? '');
    _tanggalC = TextEditingController(text: Format.tanggalPanjang(_tanggal));
    _jamC = TextEditingController(text: Format.jam(_tanggal));

    if (t != null) {
      for (final i in t.items) {
        _items.add(_ItemForm(
          id: i.id,
          nama: i.nama,
          kategoriId: i.kategoriId,
          harga: i.harga,
        ));
      }
    } else if (_sumber == SumberResi.manual) {
      _items.add(_ItemForm(kategoriId: SeedData.katLain));
    } else {
      _items.addAll([
        _ItemForm(nama: 'Nasi Goreng Spesial', kategoriId: SeedData.katKonsumsi, harga: 25000),
        _ItemForm(nama: 'Buku Tulis Sinar Dunia', kategoriId: SeedData.katEdukasi, harga: 15000),
        _ItemForm(nama: 'Barang Tidak Jelas AAA', kategoriId: SeedData.katLain, harga: 50000),
      ]);
    }
  }

  @override
  void dispose() {
    _tokoC.dispose();
    _catatanC.dispose();
    _tanggalC.dispose();
    _jamC.dispose();
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  int get _total => _items.fold(0, (sum, i) => sum + i.harga);

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal.isAfter(sekarang) ? sekarang : _tanggal,
      firstDate: DateTime(2020),
      lastDate: sekarang,
    );
    if (hasil == null) return;
    setState(() {
      _tanggal = DateTime(hasil.year, hasil.month, hasil.day, _tanggal.hour, _tanggal.minute);
      _tanggalC.text = Format.tanggalPanjang(_tanggal);
    });
  }

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_tanggal),
    );
    if (hasil == null) return;
    setState(() {
      _tanggal = DateTime(_tanggal.year, _tanggal.month, _tanggal.day, hasil.hour, hasil.minute);
      _jamC.text = Format.jam(_tanggal);
    });
  }

  void _tambahItem() {
    setState(() => _items.add(_ItemForm(kategoriId: SeedData.katLain)));
  }

  void _hapusItem(int index) {
    final item = _items.removeAt(index);
    item.dispose();
    setState(() {});
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<TransaksiProvider>();
    if (provider.isSubmitting) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final id = widget.transaksi?.id ?? IdGenerator.next('trx');
    final data = Transaksi(
      id: id,
      toko: _tokoC.text.trim(),
      tanggal: _tanggal,
      sumber: _sumber,
      catatan: _catatanC.text.trim(),
      imagePath: widget.transaksi?.imagePath,
      items: [
        for (final i in _items)
          ItemTransaksi(
            id: i.id ?? IdGenerator.next('itm'),
            transaksiId: id,
            nama: i.namaC.text.trim(),
            kategoriId: i.kategoriId!,
            harga: i.harga,
          ),
      ],
    );

    final ok = _edit ? await provider.ubah(data) : await provider.tambah(data);
    if (ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(_edit ? 'Perubahan berhasil disimpan.' : 'Resi berhasil disimpan.')),
      );
      if (mounted) navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal menyimpan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final kategori = context.watch<KategoriProvider>();
    final menyimpan = context.watch<TransaksiProvider>().isSubmitting;

    final judul = _edit
        ? 'Edit Resi'
        : (_sumber == SumberResi.manual ? 'Tambah Resi Manual' : 'Validasi Struk');

    Widget body;
    if (kategori.status == LoadStatus.error) {
      body = ErrorView(
        pesan: kategori.errorMessage ?? 'Gagal memuat kategori.',
        onRetry: kategori.muat,
      );
    } else if (kategori.status != LoadStatus.success) {
      body = const LoadingView(pesan: 'Memuat kategori...');
    } else {
      body = _buildForm(kategori);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primaryContainer,
      ),
      body: body,
      bottomNavigationBar: kategori.status == LoadStatus.success
          ? _buildBottomBar(cs, menyimpan)
          : null,
    );
  }

  InputDecoration _dekor(String label, {Widget? suffix, EdgeInsets? padding, IconData? prefixIcon}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      suffixIcon: suffix,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: cs.onSurfaceVariant) : null,
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.primary, width: 1.5)),
      contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildForm(KategoriProvider kategori) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (_hasilScan) ...[
            Container(
              height: 120,
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 40, color: cs.onSurfaceVariant),
                    Text('Preview Struk Fisik/Digital', style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 20, color: cs.tertiary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Hasil simulasi AI. Periksa dan sesuaikan sebelum menyimpan.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Informasi Resi', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tokoC,
            maxLength: 50,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: _dekor('Nama Toko / Sumber'),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return 'Nama toko wajib diisi';
              if (s.length < 2) return 'Nama toko minimal 2 karakter';
              if (s.length > 50) return 'Nama toko maksimal 50 karakter';
              return null;
            },
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _tanggalC,
                  readOnly: true,
                  onTap: _pilihTanggal,
                  decoration: _dekor('Tanggal', suffix: const Icon(Icons.calendar_today_rounded, size: 18)),
                  validator: (_) => _tanggal.isAfter(DateTime.now())
                      ? 'Tanggal/jam tidak boleh di masa depan'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _jamC,
                  readOnly: true,
                  onTap: _pilihJam,
                  decoration: _dekor('Jam', suffix: const Icon(Icons.access_time_rounded, size: 18)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SumberResi>(
            initialValue: _sumber,
            isExpanded: true,
            decoration: _dekor('Sumber Resi'),
            items: [
              for (final s in SumberResi.values)
                DropdownMenuItem(value: s, child: Text(Format.labelSumber(s))),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _sumber = v);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _catatanC,
            maxLength: 120,
            maxLines: 3,
            minLines: 2,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            decoration: _dekor('Catatan (opsional)'),
            validator: (v) => (v?.length ?? 0) > 120 ? 'Catatan maksimal 120 karakter' : null,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rincian Item (${_items.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _tambahItem,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Item'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _items.length; i++) _buildItemCard(i, kategori),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index, KategoriProvider kategori) {
    final item = _items[index];
    final kategoriValid = kategori.items.any((k) => k.id == item.kategoriId) ? item.kategoriId : null;
    final cs = Theme.of(context).colorScheme;

    return Container(
      key: item.key,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Item ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer, fontSize: 12)),
              ),
              const Spacer(),
              if (_items.length > 1)
                IconButton(
                  tooltip: 'Hapus item',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                  onPressed: () => _hapusItem(index),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: item.namaC,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: _dekor('Nama Barang', prefixIcon: Icons.shopping_bag_outlined),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return 'Nama barang wajib diisi';
              if (s.length > 40) return 'Maksimal 40 karakter';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: kategoriValid,
            isExpanded: true,
            decoration: _dekor('Kategori', prefixIcon: Icons.category_outlined),
            items: [
              for (final k in kategori.items)
                DropdownMenuItem(value: k.id, child: Text(k.nama, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() => item.kategoriId = v),
            validator: (v) => v == null ? 'Pilih kategori' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: item.hargaC,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: _dekor('Harga (Rp)', prefixIcon: Icons.payments_outlined),
            onChanged: (_) => setState(() {}),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return 'Harga wajib diisi';
              final n = int.tryParse(s);
              if (n == null || n <= 0) return 'Harus lebih dari 0';
              if (n > _maksHarga) return 'Harga maksimal ${Format.rupiah(_maksHarga)}';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme cs, bool menyimpan) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pengeluaran', style: TextStyle(fontSize: 12)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      Format.rupiah(_total),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: menyimpan ? null : _simpan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
              ),
              icon: menyimpan
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(menyimpan ? 'Menyimpan...' : (_edit ? 'Simpan Perubahan' : 'Simpan Data')),
            ),
          ],
        ),
      ),
    );
  }
}