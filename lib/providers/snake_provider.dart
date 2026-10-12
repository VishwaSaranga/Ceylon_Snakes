import 'package:flutter/material.dart';
import '../models/snake_model.dart';
import '../models/history_model.dart';
import '../services/database_service.dart';

class SnakeProvider extends ChangeNotifier {
  List<Snake> _favorites = [];
  List<ScanHistory> _history = [];

  List<Snake> get favorites => _favorites;
  List<ScanHistory> get history => _history;

  SnakeProvider() {
    _loadData();
  }

  void _loadData() {
    _favorites = DatabaseService.instance.getFavorites();
    _history = DatabaseService.instance.getHistory();
    notifyListeners();
  }

  // Favorites

  Future<void> toggleFavorite(Snake snake) async {
    await DatabaseService.instance.toggleFavorite(snake);
    _favorites = DatabaseService.instance.getFavorites();
    notifyListeners();
  }

  bool isFavorite(String snakeName) {
    return DatabaseService.instance.isFavorite(snakeName);
  }

  // History

  Future<void> addScanHistory(ScanHistory historyItem) async {
    await DatabaseService.instance.addScanHistory(historyItem);
    _history = DatabaseService.instance.getHistory();
    notifyListeners();
  }

  Future<void> deleteHistoryItem(ScanHistory historyItem) async {
    await DatabaseService.instance.deleteHistoryItem(historyItem);
    _history = DatabaseService.instance.getHistory();
    notifyListeners();
  }
}
