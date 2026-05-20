import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TableSession extends ChangeNotifier {
  static const _tableKey = 'active_table_number';

  TableSession._();
  static final TableSession instance = TableSession._();

  String? _tableNumber;
  bool _initialized = false;

  String? get tableNumber => _tableNumber;
  bool get hasTable => _tableNumber != null && _tableNumber!.isNotEmpty;
  bool get initialized => _initialized;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _tableNumber = prefs.getString(_tableKey);
    _initialized = true;
    notifyListeners();
  }

  Future<void> setTable(String tableNumber) async {
    final normalized = tableNumber.trim();
    if (normalized.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tableKey, normalized);

    _tableNumber = normalized;
    notifyListeners();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tableKey);

    _tableNumber = null;
    notifyListeners();
  }
}
