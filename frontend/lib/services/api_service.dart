import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/diagnostic_models.dart';

class ApiService {
  String baseUrl;

  ApiService({this.baseUrl = "http://10.0.2.2:8000/api"});

  void updateBaseUrl(String newUrl) {
    if (newUrl.endsWith('/')) {
      baseUrl = newUrl.substring(0, newUrl.length - 1);
    } else {
      baseUrl = newUrl;
    }
    if (!baseUrl.endsWith('/api')) {
      baseUrl = '$baseUrl/api';
    }
  }

  String get serverRoot {
    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    }
    return baseUrl;
  }

  String getAbsoluteAssetUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    final cleanPath = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$serverRoot$cleanPath';
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getModelStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/models/status')).timeout(const Duration(seconds: 6));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch model status: ${response.statusCode}');
  }

  Future<List<CropModel>> getCrops() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/crops')).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['crops'] as List<dynamic>? ?? [];
        return list.map((e) => CropModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Fallback local list
    }
    return [
      CropModel(name: 'Guava', scientificName: 'Psidium guajava', description: 'Tropical fruit vulnerable to canker and rust.', diseases: ['Guava_Canker', 'Guava_Dot', 'Guava_Healthy', 'Guava_Mummification', 'Guava_Rust'], optimalPhRange: '6.0 - 7.5', optimalEcRange: '< 1800 µS/cm'),
      CropModel(name: 'Papaya', scientificName: 'Carica papaya', description: 'Sensitive to mosaic and anthracnose rot.', diseases: ['Papaya_Anthracnose', 'Papaya_Black_Spot', 'Papaya_Healthy', 'Papaya_Mosaic', 'Papaya_Ring_Spot'], optimalPhRange: '6.0 - 7.0', optimalEcRange: '< 1500 µS/cm'),
      CropModel(name: 'Brinjal', scientificName: 'Solanum melongena', description: 'Eggplant affected by wilt and little leaf.', diseases: ['Brinjal_Bacterial_Wilt', 'Brinjal_Cercospora_Leaf_Spot', 'Brinjal_Healthy', 'Brinjal_Little_Leaf', 'Brinjal_Tobacco_Mosaic_Virus'], optimalPhRange: '5.5 - 6.8', optimalEcRange: '< 2000 µS/cm'),
      CropModel(name: 'Castor', scientificName: 'Ricinus communis', description: 'Major oilseed prone to bacterial blight.', diseases: ['Castor_Bacterial_Blight', 'Castor_Cercospora', 'Castor_Healthy', 'Castor_Rust', 'Castor_Seedling_Blight'], optimalPhRange: '5.5 - 7.0', optimalEcRange: '< 2000 µS/cm'),
      CropModel(name: 'Cumin', scientificName: 'Cuminum cyminum', description: 'Valuable spice vulnerable to wilt and mildew.', diseases: ['Cumin_Alternaria_Blight', 'Cumin_Fusarium_Wilt', 'Cumin_Healthy', 'Cumin_Powdery_Mildew'], optimalPhRange: '6.8 - 8.2', optimalEcRange: '< 1600 µS/cm'),
    ];
  }

  Future<LeafPredictionResult> predictLeafDisease({
    required Uint8List imageBytes,
    required String filename,
    String? crop,
  }) async {
    final uri = Uri.parse('$baseUrl/disease/predict');
    final request = http.MultipartRequest('POST', uri);

    final ext = filename.split('.').last.toLowerCase();
    final mediaType = (ext == 'png') ? MediaType('image', 'png') : MediaType('image', 'jpeg');

    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: filename, contentType: mediaType),
    );

    if (crop != null && crop.isNotEmpty) {
      request.fields['crop'] = crop;
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonMap = json.decode(utf8.decode(response.bodyBytes));
      return LeafPredictionResult.fromJson(jsonMap);
    }
    throw Exception('Leaf prediction failed (${response.statusCode}): ${response.body}');
  }

  Future<SoilPredictionResult> predictSoilHealth({
    required String crop,
    required Map<String, dynamic> soilReadings,
  }) async {
    final uri = Uri.parse('$baseUrl/soil/predict');
    final body = json.encode({
      'crop': crop,
      'soil_readings': soilReadings,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(utf8.decode(response.bodyBytes));
      return SoilPredictionResult.fromJson(jsonMap);
    }
    throw Exception('Soil prediction failed (${response.statusCode}): ${response.body}');
  }

  Future<IntegratedAnalysisResult> analyzeMultimodal({
    required String crop,
    bool isPairedSample = true,
    Uint8List? imageBytes,
    String? filename,
    Map<String, dynamic>? soilReadings,
  }) async {
    final uri = Uri.parse('$baseUrl/integration/analyze');
    final request = http.MultipartRequest('POST', uri);

    request.fields['crop'] = crop;
    request.fields['is_paired_sample'] = isPairedSample.toString();

    if (soilReadings != null && soilReadings.isNotEmpty) {
      request.fields['soil_readings'] = json.encode(soilReadings);
    }

    if (imageBytes != null && filename != null) {
      final ext = filename.split('.').last.toLowerCase();
      final mediaType = (ext == 'png') ? MediaType('image', 'png') : MediaType('image', 'jpeg');
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: filename, contentType: mediaType),
      );
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 40));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonMap = json.decode(utf8.decode(response.bodyBytes));
      return IntegratedAnalysisResult.fromJson(jsonMap);
    }
    throw Exception('Integrated analysis failed (${response.statusCode}): ${response.body}');
  }

  Future<Map<String, dynamic>> generateRecommendations({
    required String crop,
    required String conditionOrParameter,
    String? parameterLevel,
    Map<String, double>? soilReadings,
  }) async {
    final uri = Uri.parse('$baseUrl/recommendations/generate');
    final body = json.encode({
      'crop': crop,
      'condition_or_parameter': conditionOrParameter,
      if (parameterLevel != null) 'parameter_level': parameterLevel,
      if (soilReadings != null) 'soil_readings': soilReadings,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Recommendations query failed (${response.statusCode}): ${response.body}');
  }

  Future<List<DiagnosisRecordModel>> getHistory({int skip = 0, int limit = 50, String? crop}) async {
    String url = '$baseUrl/history?skip=$skip&limit=$limit';
    if (crop != null && crop.isNotEmpty && crop != 'All') {
      url += '&crop=${Uri.encodeComponent(crop)}';
    }

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final list = data['records'] as List<dynamic>? ?? [];
      return list.map((e) => DiagnosisRecordModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch history (${response.statusCode}): ${response.body}');
  }

  Future<DiagnosisRecordModel> getHistoryDetail(String recordId) async {
    final uri = Uri.parse('$baseUrl/history/$recordId');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return DiagnosisRecordModel.fromJson(data);
    }
    throw Exception('Failed to fetch record $recordId');
  }

  Future<bool> deleteHistoryRecord(int id) async {
    final uri = Uri.parse('$baseUrl/history/$id');
    final response = await http.delete(uri).timeout(const Duration(seconds: 10));
    return response.statusCode == 200;
  }
}
