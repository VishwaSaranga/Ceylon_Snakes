import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UnverifiedImageException implements Exception {
  final String message;
  UnverifiedImageException(
      [this.message =
          'Image could not be clearly verified. Please capture a clearer photo or try Offline mode.']);
  @override
  String toString() => message;
}

class NoInternetException implements Exception {
  final String message;
  NoInternetException(
      [this.message = 'No internet connection. Please switch to Offline mode']);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error. Please try Offline mode.']);
  @override
  String toString() => message;
}

class ApiService {
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get apiKey => dotenv.env['CEYLON_SNAKE_API'] ?? '';

  static const Map<String, String> speciesDisplayNameMap = {
    'bungarus_caeruleus': 'Common krait (තෙල් කරවලා)',
    'coelognathus_helena': 'Trinket snake (කටකලුවා)',
    'craspedocephalus_trigonocephalus':
        'Sri Lankan green pit viper (පළා පොළඟා)',
    'daboia_russelii': "Russell's Viper (තිත් පොළඟා)",
    'hypnale_hypnale': 'Hump-nosed viper (කුණුකටුවා / පොළොං තෙලිස්සා)',
    'lycodon_aulicus': 'Common wolf snake (මල් රදනකයා)',
    'naja_naja': 'Indian cobra (නයා)',
    'oligodon_arnensis': 'Common kukri snake (අරණී දත්කැටියා)',
  };

  static String formatSpeciesDisplayName(String rawSpecies) {
    if (rawSpecies.isEmpty || rawSpecies == 'Unknown Snake') {
      return rawSpecies;
    }

    final normalized =
        rawSpecies.toLowerCase().trim().replaceAll(RegExp(r'[\s\-]+'), '_');

    if (speciesDisplayNameMap.containsKey(normalized)) {
      return speciesDisplayNameMap[normalized]!;
    }

    if (rawSpecies.contains('(') || rawSpecies.contains(')')) {
      return rawSpecies;
    }

    return rawSpecies
        .split(RegExp(r'[_\s\-]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  static MediaType _getMediaType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.png') {
      return MediaType('image', 'png');
    } else if (ext == '.webp') {
      return MediaType('image', 'webp');
    } else if (ext == '.bmp') {
      return MediaType('image', 'bmp');
    } else {
      return MediaType('image', 'jpeg');
    }
  }

  static Future<Map<String, dynamic>> predict(File imageFile) async {
    if (!await imageFile.exists()) {
      throw ServerException('Selected image file could not be found.');
    }

    try {
      final List<ConnectivityResult> connectivityResults =
          await Connectivity().checkConnectivity();
      bool isOffline =
          connectivityResults.every((r) => r == ConnectivityResult.none);

      if (isOffline) {
        throw NoInternetException(
            'No internet connection. Please switch to Offline mode');
      }
    } on NoInternetException {
      rethrow;
    } catch (e) {
      debugPrint('Connectivity check notice: $e');
    }

    final String cleanUrl = apiUrl.trim();
    final String cleanApiKey = apiKey.trim();

    final Uri uri = Uri.parse(cleanUrl);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $cleanApiKey';
    request.headers['x-api-key'] = cleanApiKey;
    request.headers['X-API-Key'] = cleanApiKey;
    request.headers['api-key'] = cleanApiKey;
    request.headers['Accept'] = 'application/json';

    final mediaType = _getMediaType(imageFile.path);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: mediaType,
      ),
    );

    debugPrint('API URL: $cleanUrl');
    debugPrint('Image Path: ${imageFile.path}');
    debugPrint('Media Type: $mediaType');
    debugPrint('Headers: ${request.headers}');

    http.Response response;
    try {
      final http.StreamedResponse streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));

      response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ServerException(
          'Request timed out. Please try again or switch to Offline mode.');
    } on SocketException {
      throw NoInternetException(
          'Cannot reach server. Please check your internet connection or switch to Offline mode.');
    } on http.ClientException catch (e) {
      throw ServerException(
          'Network connection error: ${e.message}. Please switch to Offline mode.');
    } catch (e) {
      if (e is NoInternetException ||
          e is ServerException ||
          e is UnverifiedImageException) {
        rethrow;
      }
      throw ServerException(
          'Failed to connect to server. Please try Offline mode.');
    }

    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> jsonResponse;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          jsonResponse = decoded;
        } else if (decoded is List &&
            decoded.isNotEmpty &&
            decoded[0] is Map<String, dynamic>) {
          jsonResponse = decoded[0];
        } else {
          throw const FormatException('Unexpected response structure');
        }
      } catch (e) {
        throw ServerException(
            'Failed to parse server response. Please try again or switch to Offline mode.');
      }

      Map<String, dynamic> data = jsonResponse;
      if (jsonResponse.containsKey('predictions') &&
          jsonResponse['predictions'] is List &&
          (jsonResponse['predictions'] as List).isNotEmpty) {
        final firstPred = jsonResponse['predictions'][0];
        if (firstPred is Map<String, dynamic>) {
          data = firstPred;
        }
      } else if (jsonResponse.containsKey('data') &&
          jsonResponse['data'] is Map<String, dynamic>) {
        data = jsonResponse['data'];
      }

      final String decision =
          (data['decision'] ?? jsonResponse['decision'] ?? 'ACCEPT')
              .toString()
              .trim();

      if (decision.toUpperCase() != 'ACCEPT') {
        throw UnverifiedImageException(
          'Image could not be clearly verified. Please capture a clearer photo or try Offline mode.',
        );
      }

      final String rawSpecies = (data['predicted_species'] ??
              data['label'] ??
              data['snake_name'] ??
              data['name'] ??
              data['species'] ??
              jsonResponse['predicted_species'] ??
              'Unknown Snake')
          .toString()
          .trim();

      final String label = formatSpeciesDisplayName(rawSpecies);

      double confidence = 0.0;
      final rawConf = data['species_confidence'] ??
          data['confidence'] ??
          data['score'] ??
          data['accuracy'] ??
          data['probability'] ??
          jsonResponse['species_confidence'] ??
          0.0;
      if (rawConf is num) {
        confidence = rawConf.toDouble();
      } else if (rawConf is String) {
        confidence = double.tryParse(rawConf.replaceAll('%', '').trim()) ?? 0.0;
      }
      if (confidence > 1.0) {
        confidence = confidence / 100.0;
      }

      int? predictedVenom;
      final rawVenom = data['predicted_venom'] ??
          data['venom_level'] ??
          data['venomous'] ??
          data['is_venomous'] ??
          jsonResponse['predicted_venom'];

      if (rawVenom != null) {
        if (rawVenom is int) {
          predictedVenom = rawVenom;
        } else if (rawVenom is num) {
          predictedVenom = rawVenom.toInt();
        } else if (rawVenom is bool) {
          predictedVenom = rawVenom ? 1 : 0;
        } else if (rawVenom is String) {
          final parsed = int.tryParse(rawVenom.trim());
          if (parsed != null) {
            predictedVenom = parsed;
          } else {
            final lower = rawVenom.toLowerCase().trim();
            if (lower.contains('non') ||
                lower == 'none' ||
                lower == 'safe' ||
                lower == 'harmless') {
              predictedVenom = 0;
            } else if (lower.contains('venom') ||
                lower.contains('toxic') ||
                lower.contains('danger')) {
              predictedVenom = 1;
            }
          }
        }
      }

      return {
        'label': label,
        'raw_species': rawSpecies,
        'confidence': confidence,
        'predicted_venom': predictedVenom,
        'decision': decision,
      };
    } else {
      String errorMsg = 'Server error: Code ${response.statusCode}';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map) {
          final detail =
              errorData['detail'] ?? errorData['message'] ?? errorData['error'];
          if (detail != null) {
            errorMsg = 'Server error: Code ${response.statusCode} ($detail)';
          }
        } else if (response.body.isNotEmpty && response.body.length < 150) {
          errorMsg =
              'Server error: Code ${response.statusCode} - ${response.body}';
        }
      } catch (_) {
        if (response.body.isNotEmpty && response.body.length < 150) {
          errorMsg =
              'Server error: Code ${response.statusCode} - ${response.body}';
        }
      }
      throw ServerException(errorMsg);
    }
  }
}
