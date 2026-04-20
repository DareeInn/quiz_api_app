import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey =
      'qa_sk_1f9430c34619fffdb2f47ec8c0d6c9774e393555';
  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';

  // Generate a hint for a given question
  static Future<String> generateHint(String question) async {
    final prompt = "Provide a helpful hint for this quiz question: $question";
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful quiz assistant.'},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 60,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      return 'No hint available.';
    }
  }

  // Generate a review summary for missed topics
  static Future<String> generateReviewSummary(List<String> missedTopics) async {
    final prompt =
        "Summarize the user's weak areas and suggest next steps. Missed topics: ${missedTopics.join(', ')}";
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful quiz coach.'},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 100,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      return 'No review summary available.';
    }
  }

  // Extract intent and topic from user input
  static Future<Map<String, String>> extractIntent(String userInput) async {
    final prompt =
        "Extract the quiz topic and difficulty from this user request: '$userInput'. Respond as JSON with 'topic' and 'difficulty'.";
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an intent extraction assistant.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 30,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return jsonDecode(content);
    } else {
      return {'topic': '', 'difficulty': ''};
    }
  }
}
