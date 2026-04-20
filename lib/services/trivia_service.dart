import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../app_config.dart';

class TriviaService {
  static Future<List<Question>> fetchQuestions({
    String topic = '',
    String difficulty = 'any',
  }) async {
    final params = <String, String>{'limit': '10'};
    if (topic.isNotEmpty) params['category'] = topic;
    if (difficulty != 'any') params['difficulty'] = difficulty;
    final url = Uri.https('quizapi.io', '/api/v1/questions', params);

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
