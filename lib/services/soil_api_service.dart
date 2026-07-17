import 'dart:convert';
import 'package:http/http.dart' as http;

/// Represents the high-fidelity geotechnical analysis result returned by server.py.
class SoilAnalysisResult {
  final String soilClassCode;
  final String soilClassName;
  final String description;
  final double cbrPercent;
  final double groupIndex;
  final String compactionRecommendation;
  final double classificationConfidence;
  final String engine;

  SoilAnalysisResult({
    required this.soilClassCode,
    required this.soilClassName,
    required this.description,
    required this.cbrPercent,
    required this.groupIndex,
    required this.compactionRecommendation,
    required this.classificationConfidence,
    required this.engine,
  });

  /// Factory constructor to instantiate from backend response map.
  factory SoilAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SoilAnalysisResult(
      soilClassCode: json['soil_class_code'] ?? 'N/A',
      soilClassName: json['soil_class_name'] ?? 'Unknown Soil',
      description: json['description'] ?? 'No geological description provided.',
      cbrPercent: (json['CBR_percent'] as num?)?.toDouble() ?? 0.0,
      groupIndex: (json['group_index'] as num?)?.toDouble() ?? 0.0,
      compactionRecommendation: json['compaction_recommendation'] ?? 'Standard compaction checks recommended.',
      classificationConfidence: (json['classification_confidence'] as num?)?.toDouble() ?? 0.0,
      engine: json['engine'] ?? 'Fallback Engine',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'soil_class_code': soilClassCode,
      'soil_class_name': soilClassName,
      'description': description,
      'CBR_percent': cbrPercent,
      'group_index': groupIndex,
      'compaction_recommendation': compactionRecommendation,
      'classification_confidence': classificationConfidence,
      'engine': engine,
    };
  }
}

/// Core API routing client for the local FastAPI Geotechnical Server.
class SoilApiService {
  /// Base API URL.
  /// - Use `http://127.0.0.1:8000` for Web / Desktop / iOS Simulators.
  /// - Use `http://10.0.2.2:8000` for Android Emulators.
  static String baseUrl = 'http://127.0.0.1:8000';

  /// Performs geotechnical classification and estimation by POSTing raw parameters.
  static Future<SoilAnalysisResult> analyzeSoil({
    required double pl,
    required double pi,
    required double d10,
    required double d30,
    required double d60,
    required double omc,
    required double mdd,
    double? cu,
    double? cc,
  }) async {
    final url = Uri.parse('$baseUrl/analyze-soil');
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final Map<String, dynamic> body = {
      'PL': pl,
      'PI': pi,
      'D10': d10,
      'D30': d30,
      'D60': d60,
      'Cu': cu,
      'Cc': cc,
      'OMC': omc,
      'MDD': mdd,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return SoilAnalysisResult.fromJson(responseData);
      } else {
        throw Exception(
          'Server response failed (${response.statusCode}): ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Connection failed. Verify server.py is running. Details: $e');
    }
  }

  /// Pings the server to verify active status.
  static Future<bool> pingServer() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['status'] == 'online';
      }
    } catch (_) {}
    return false;
  }

  /// Calls the FastAPI backend to generate and download the template-injected multi-tab Excel spreadsheet.
  static Future<List<int>> exportSieveExcel({
    required String region,
    required String dateSampled,
    required String testedBy,
    required String sampleDescription,
    required String location,
    required List<Map<String, dynamic>> samples,
  }) async {
    final url = Uri.parse('$baseUrl/api/export-sieve');
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final Map<String, dynamic> body = {
      'region': region,
      'date_sampled': dateSampled,
      'tested_by': testedBy,
      'sample_description': sampleDescription,
      'location': location,
      'samples': samples,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
          'Export failed (${response.statusCode}): ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Connection to export server failed. Details: $e');
    }
  }

  /// Uploads sieve log sheet image bytes to the backend to parse them with Gemini.
  static Future<Map<String, dynamic>> parseSieveImage({
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final url = Uri.parse('$baseUrl/api/parse-sieve-image');
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ),
    );
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to parse image (${response.statusCode}): ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Connection to image parsing server failed. Details: $e');
    }
  }

  /// Uploads Excel spreadsheet bytes to the backend to convert them into a styled Word Document.
  static Future<List<int>> convertExcelToWord({
    required List<int> excelBytes,
    required String fileName,
  }) async {
    final url = Uri.parse('$baseUrl/api/convert-excel-to-word');
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        excelBytes,
        filename: fileName,
      ),
    );
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
          'Failed to convert Excel to Word (${response.statusCode}): ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Connection to conversion server failed. Details: $e');
    }
  }
}
