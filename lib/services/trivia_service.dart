import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../app_config.dart';

class TriviaService {
  static Future<List<Question>> fetchQuestions() async {
    final url = Uri.parse('https://quizapi.io/api/v1/questions?limit=10');

    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $quizApiKey',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load questions. Status: ${response.statusCode}. Body: ${response.body}',
      );
    }

    final decoded = json.decode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response format: $decoded');
    }

    if (decoded['success'] != true) {
      throw Exception('API returned success=false. Body: ${response.body}');
    }

    final data = decoded['data'];

    if (data is! List) {
      throw Exception('API data is not a list. Body: ${response.body}');
    }

    return data
        .map<Question>((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();
  }
}
