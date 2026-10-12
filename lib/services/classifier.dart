import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:ceylon_snakes/services/api_service.dart';

export 'package:ceylon_snakes/services/api_service.dart'
    show UnverifiedImageException, NoInternetException, ServerException;

enum ScanMode { offline, online }

class Classifier {
  // Singleton instance
  static final Classifier _instance = Classifier._internal();
  factory Classifier() => _instance;
  Classifier._internal();

  static const String modelPath = 'assets/models/model.tflite';
  static const String labelsPath = 'assets/models/labels.txt';

  static String get apiUrl => ApiService.apiUrl;
  static String get apiKey => ApiService.apiKey;

  bool _isModelLoaded = false;

  /// Load the offline model and labels
  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: modelPath,
        labels: labelsPath,
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      debugPrint('Model loaded: $res');
      _isModelLoaded = true;
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  /// Run prediction using the specified mode (default: offline)
  Future<Map<String, dynamic>?> predict(
    File imageFile, {
    ScanMode mode = ScanMode.offline,
  }) async {
    if (mode == ScanMode.online) {
      return await predictOnline(imageFile);
    } else {
      return await predictOffline(imageFile);
    }
  }

  /// Run offline inference on an image file using TFLite
  Future<Map<String, dynamic>?> predictOffline(File imageFile) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 1,
        threshold: 0.1,
        imageMean: 0.0,
        imageStd: 1.0,
      );

      debugPrint('Offline Predictions: $recognitions');

      if (recognitions == null || recognitions.isEmpty) {
        return null;
      }

      var topResult = recognitions[0];

      return {
        'index': topResult['index'],
        'label': topResult['label'],
        'confidence': (topResult['confidence'] as num).toDouble(),
        'scan_mode': ScanMode.offline,
      };
    } catch (e, stackTrace) {
      debugPrint('Error during offline prediction: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// Run online prediction via backend HTTP API
  Future<Map<String, dynamic>?> predictOnline(File imageFile) async {
    // Step A: Network Check
    final List<ConnectivityResult> connectivityResults =
        await Connectivity().checkConnectivity();
    bool isOffline =
        connectivityResults.every((r) => r == ConnectivityResult.none);

    if (isOffline) {
      throw NoInternetException(
        'No internet connection. Please switch to Offline mode',
      );
    }

    try {
      final apiResult = await ApiService.predict(imageFile);

      final String label = apiResult['label'];
      final double confidence = apiResult['confidence'];
      final int? predictedVenom = apiResult['predicted_venom'];
      final String decision = apiResult['decision'];

      int index = _mapLabelToIndex(label);

      return {
        'index': index,
        'label': label,
        'raw_species': apiResult['raw_species'],
        'confidence': confidence,
        'predicted_venom': predictedVenom,
        'decision': decision,
        'scan_mode': ScanMode.online,
      };
    } on UnverifiedImageException {
      rethrow;
    } on NoInternetException {
      rethrow;
    } on ServerException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('SocketException during online prediction: $e');
      throw ServerException(
          'Cannot reach server. Please check your internet or try Offline mode.');
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException during online prediction: $e');
      throw ServerException(
          'Request timed out. Please try again or switch to Offline mode.');
    } catch (e) {
      if (e is UnverifiedImageException) rethrow;
      debugPrint('Error during online prediction: $e');
      throw ServerException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Helper to map label string to index if not supplied by server
  int _mapLabelToIndex(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('krait') ||
        lower.contains('bungarus') ||
        lower.contains('කරවැලා') ||
        lower.contains('කරවලා')) {
      return 0;
    }
    if (lower.contains('russell') ||
        lower.contains('daboia') ||
        (lower.contains('viper') && lower.contains('තිත්')) ||
        lower.contains('තිත් පොළඟා')) {
      return 1;
    }
    if (lower.contains('wolf') ||
        lower.contains('lycodon') ||
        lower.contains('මල්')) {
      return 2;
    }
    if (lower.contains('cobra') ||
        lower.contains('naja') ||
        lower.contains('නාගයා') ||
        lower.contains('නයා')) {
      return 3;
    }
    if (lower.contains('green pit') ||
        lower.contains('trimeresurus') ||
        lower.contains('craspedocephalus') ||
        lower.contains('පළා')) {
      return 4;
    }
    if (lower.contains('kukri') ||
        lower.contains('oligodon') ||
        lower.contains('කුක්රි') ||
        lower.contains('දත්කැටියා')) {
      return 5;
    }
    if (lower.contains('hump-nosed') ||
        lower.contains('hypnale') ||
        lower.contains('කුණකටුවා') ||
        lower.contains('කුණුකටුවා') ||
        lower.contains('තෙලිස්සා')) {
      return 6;
    }
    if (lower.contains('trinket') ||
        lower.contains('coelognathus') ||
        lower.contains('කටකලුවා')) {
      return 7;
    }
    return -1;
  }

  void close() {
    Tflite.close();
  }
}
