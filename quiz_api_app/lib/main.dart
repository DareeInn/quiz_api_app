import 'package:flutter/material.dart';
import 'services/trivia_service.dart';
import 'app_config.dart';
import 'models/question.dart';
import 'screens/result_screen.dart';

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
  State<TestLoader> createState() => TestLoaderState();
}

class TestLoaderState extends State<TestLoader> {
  String message = 'Loading...';

  List<Question> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final result = await TriviaService.fetchQuestions();
      setState(() {
        questions = result;
        message = '';
        currentIndex = 0;
        score = 0;
        answered = false;
        selectedAnswer = null;
      });
    } catch (e) {
      setState(() {
        message =
            'Could not load questions. Please check your internet connection and try again.';
      });
    }
  }

  void answerQuestion(String selected) {
    if (answered) return;

    final correct = questions[currentIndex].correctAnswer;

    setState(() {
      answered = true;
      selectedAnswer = selected;
      if (selected == correct) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        answered = false;
        selectedAnswer = null;
        currentIndex++;
        if (currentIndex >= questions.length) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                score: score,
                totalQuestions: questions.length,
                onRestart: restartQuiz,
              ),
            ),
          );
        }
      });
    });
  }

  void restartQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyApp()),
    );
  }

  Color getAnswerColor(String answer, Question question) {
    if (!answered) return Colors.purple;
    if (answer == question.correctAnswer) return Colors.green;
    if (answer == selectedAnswer && answer != question.correctAnswer)
      return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (message.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            if (message.startsWith('Could not load'))
              ElevatedButton(
                onPressed: loadQuestions,
                child: const Text('Retry'),
              ),
          ],
        ),
      );
    }

    final question = questions[currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Question ${currentIndex + 1}/${questions.length}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Text(question.question, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 20),
          ...question.answers.map((answer) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: getAnswerColor(answer, question),
                ),
                onPressed: answered ? null : () => answerQuestion(answer),
                child: Text(answer),
              ),
            );
          }),
        ],
      ),
    );
  }
}
