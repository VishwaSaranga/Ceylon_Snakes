import 'package:hive_flutter/hive_flutter.dart';
import '../models/snake_model.dart';
import '../models/history_model.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  late Box<Snake> _favoritesBox;
  late Box<ScanHistory> _historyBox;

  Future<void> initDB() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SnakeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScanHistoryAdapter());
    }

    // Open Boxes
    _favoritesBox = await Hive.openBox<Snake>('favoritesBox');
    _historyBox = await Hive.openBox<ScanHistory>('historyBox');
  }

  // Favorites Methods

  Future<void> toggleFavorite(Snake snake) async {
    if (_favoritesBox.containsKey(snake.name)) {
      await _favoritesBox.delete(snake.name);
    } else {
      snake.isFavorite = true;
      await _favoritesBox.put(snake.name, snake);
    }
  }

  bool isFavorite(String snakeName) {
    return _favoritesBox.containsKey(snakeName);
  }

  List<Snake> getFavorites() {
    return _favoritesBox.values.toList();
  }

  // History Methods

  Future<void> addScanHistory(ScanHistory history) async {
    await _historyBox.add(history);
  }

  Future<void> deleteHistoryItem(ScanHistory history) async {
    await history.delete();
  }

  List<ScanHistory> getHistory() {
    // Return history sorted by date
    final history = _historyBox.values.toList();
    history.sort((a, b) => b.scanDate.compareTo(a.scanDate));
    return history;
  }
}
