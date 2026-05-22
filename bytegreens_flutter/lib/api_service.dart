import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String simpleBackend = 'http://10.0.2.2:8000';
  static const String cvBackend = 'http://10.0.2.2:8001';

  static Future<Map<String, dynamic>> fetchWeather() async {
    final uri = Uri.parse('$simpleBackend/weather');
    final response = await http.get(uri);
    return _decodeResponse(response);
  }

  static Future<List<dynamic>> fetchMarket() async {
    final uri = Uri.parse('$simpleBackend/market');
    final response = await http.get(uri);
    final body = _decodeResponse(response);
    return body['listings'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> fetchStats() async {
    final uri = Uri.parse('$simpleBackend/stats');
    final response = await http.get(uri);
    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    final uri = Uri.parse('$cvBackend/cv/analyze');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = _decodeResponse(response);
    return body;
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw HttpException(
      'Request failed (${response.statusCode}): ${response.reasonPhrase}',
      uri: response.request?.url,
    );
  }
}
