import 'package:flutter/material.dart';
import 'services/trivia_service.dart';
import 'app_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: TestLoader())),
    );
  }
}

class TestLoader extends StatefulWidget {
  const TestLoader({super.key});

  @override
  State<TestLoader> createState() => _TestLoaderState();
}

class _TestLoaderState extends State<TestLoader> {
  String message = 'Loading...';

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    print('QUIZ KEY: $quizApiKey');
    print('QUIZ KEY LENGTH: ${quizApiKey.length}');
    try {
      final questions = await TriviaService.fetchQuestions();
      setState(() {
        message = 'Loaded ${questions.length} questions!';
      });
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(child: Text(message)),
    );
  }
}
