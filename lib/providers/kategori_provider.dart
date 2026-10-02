import 'package:flutter/foundation.dart';

import '../models/kategori.dart';
import '../repositories/kategori_repository.dart';
import '../utils/helpers.dart';

class KategoriProvider extends ChangeNotifier {
  KategoriProvider(this._repo);

  final KategoriRepository _repo;

  List<Kategori> _items = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  List<Kategori> get items => List.unmodifiable(_items);
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Kategori? byId(String id) {
    for (final k in _items) {
      if (k.id == id) return k;
    }
    return null;
  }

  String namaDari(String id) => byId(id)?.nama ?? 'Tidak diketahui';

  Future<void> muat() async {
    if (_status == LoadStatus.loading) return;
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repo.getAll();
      _status = LoadStatus.success;
    } catch (e) {
      _status = LoadStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }
}