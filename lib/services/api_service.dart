import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://npnzujqsmlowrvpnnpef.supabase.co/rest/v1';
  static const String apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wbnp1anFzbWxvd3J2cG5ucGVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NTU4MDEsImV4cCI6MjA2NjMzMTgwMX0.tSW3I6mI2XNjRxKp-f29g1yXs5T9f_pZ_XhzfWT4kKU';

  static Map<String, String> get headers => {
    'apikey': apiKey,
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  static Future<List<dynamic>> fetch(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/$endpoint',
    ).replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch $endpoint');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post to $endpoint');
    }
  }

  static Future<dynamic> patch(
    String endpoint,
    int id,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$baseUrl/$endpoint?id=eq.$id');
    final response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to patch $endpoint');
    }
  }
}
