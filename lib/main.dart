import 'package:flutter/material.dart';
import 'models/question.dart';
import 'services/trivia_service.dart';
import 'services/ai_service.dart';
import 'services/voice_service.dart';
import 'models/user_performance.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz API App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const QuizHomePage(),
    );
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  String message = 'Loading...';

  List<Question> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  String? selectedAnswer;
  bool canProceed = false;

  UserPerformance userPerformance = UserPerformance();
  String? hint;
  bool showHintButton = false;
  bool hintLoading = false;
  DateTime? questionStartTime;

  String quizTopic = '';
  String quizDifficulty = 'any';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startQuizWithSearch(context);
    });
  }

  void startQuizWithSearch(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          onSearch: (topic, difficulty) {
            Navigator.pop(context, {'topic': topic, 'difficulty': difficulty});
          },
        ),
      ),
    );
    if (result != null && result is Map<String, String>) {
      setState(() {
        quizTopic = result['topic'] ?? '';
        quizDifficulty = result['difficulty'] ?? 'any';
      });
      loadQuestions();
    }
  }

  Future<void> loadQuestions() async {
    setState(() {
      message = 'Loading...';
    });
    try {
      final result = await TriviaService.fetchQuestions(
        topic: quizTopic,
        difficulty: quizDifficulty,
      );
      setState(() {
        questions = result;
        message = '';
        currentIndex = 0;
        score = 0;
        answered = false;
        selectedAnswer = null;
        showHintButton = false;
        hint = null;
        canProceed = false;
        questionStartTime = DateTime.now();
        userPerformance.reset();
      });
    } catch (e) {
      setState(() {
        message =
            'Could not load questions. Please check your internet connection and try again.';
      });
    }
  }

  void answerQuestion(String selected) async {
    if (answered) return;

    final correct = questions[currentIndex].correctAnswer;
    final wasCorrect = selected == correct;
    final now = DateTime.now();
    final responseTime = questionStartTime != null
        ? now.difference(questionStartTime!).inSeconds
        : 0;
    userPerformance.recordAnswer(
      correct: wasCorrect,
      category: questions[currentIndex]
          .question, // Replace with category if available
      responseTime: responseTime,
    );

    setState(() {
      answered = true;
      selectedAnswer = selected;
      canProceed = false;
      showHintButton = !wasCorrect;
      hint = null;
    });

    // Show feedback SnackBar
    final snackBar = SnackBar(
      content: Text(
        wasCorrect ? '✅ Correct!' : '❌ Wrong! Correct: $correct',
        style: const TextStyle(fontSize: 18),
      ),
      backgroundColor: wasCorrect ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 2500),
      margin: const EdgeInsets.all(16),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    setState(() {
      canProceed = true;
    });
  }

  void nextQuestion() {
    // Adaptive difficulty: adjust for next fetch if needed
    if (userPerformance.correctStreak >= 3) {
      quizDifficulty = 'Medium';
    } else if (userPerformance.wrongStreak >= 2) {
      quizDifficulty = 'Easy';
    }
    if (currentIndex + 1 >= questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            totalQuestions: questions.length,
            missedTopics: userPerformance.missedTopics,
          ),
        ),
      );
    } else {
      setState(() {
        currentIndex++;
        answered = false;
        selectedAnswer = null;
        showHintButton = false;
        hint = null;
        canProceed = false;
        questionStartTime = DateTime.now();
      });
    }
  }

  // Add this override to reload questions when Play Again is pressed
  @override
  void didUpdateWidget(covariant QuizHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When QuizHomePage is pushed again, reload questions
    loadQuestions();
    setState(() {
      currentIndex = 0;
      score = 0;
      answered = false;
      selectedAnswer = null;
    });
  }

  Color getAnswerColor(String answer, Question question) {
    if (!answered) return Colors.purple;

    if (answer == question.correctAnswer) {
      return Colors.green;
    }

    if (answer == selectedAnswer && answer != question.correctAnswer) {
      return Colors.red;
    }

    return Colors.grey.shade300;
  }

  Widget getAnswerIcon(String answer, Question question) {
    if (!answered) return const SizedBox.shrink();
    if (answer == question.correctAnswer) {
      return const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(Icons.check_circle, color: Colors.white, size: 22),
      );
    }
    if (answer == selectedAnswer && answer != question.correctAnswer) {
      return const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(Icons.cancel, color: Colors.white, size: 22),
      );
    }
    return const SizedBox.shrink();
  }

  Color getTextColor(String answer, Question question) {
    if (!answered) return Colors.white;

    if (answer == question.correctAnswer) {
      return Colors.white;
    }

    if (answer == selectedAnswer && answer != question.correctAnswer) {
      return Colors.white;
    }

    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    if (message.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz API App'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: loadQuestions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1}/${questions.length}'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: questions.isEmpty
                ? 0
                : (currentIndex + 1) / questions.length,
            minHeight: 6,
            backgroundColor: Colors.purple.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ...question.answers.map((answer) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getAnswerColor(answer, question),
                          foregroundColor: getTextColor(answer, question),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: answered
                            ? null
                            : () => answerQuestion(answer),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                answer,
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            getAnswerIcon(answer, question),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => VoiceService.speak(question.question),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Listen'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (showHintButton && answered)
                Center(
                  child: hintLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: () async {
                            setState(() {
                              hintLoading = true;
                            });
                            final h = await AIService.generateHint(
                              question.question,
                            );
                            setState(() {
                              hint = h;
                              hintLoading = false;
                            });
                          },
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Show Hint'),
                        ),
                ),
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Hint: $hint',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.deepOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (answered)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: canProceed ? nextQuestion : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      currentIndex + 1 >= questions.length
                          ? 'See Results'
                          : 'Next',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<String> missedTopics;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.missedTopics,
  });

  String getPerformanceMessage() {
    final percent = score / totalQuestions;
    if (percent == 1.0) return 'Perfect! 🎉';
    if (percent >= 0.8) return 'Excellent! 👏';
    if (percent >= 0.6) return 'Good Job! 👍';
    if (percent >= 0.4) return 'Keep Practicing! 💪';
    return 'Try Again!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quiz Complete!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Score: $score / $totalQuestions',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 16),
              Text(
                getPerformanceMessage(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<String>(
                future: AIService.generateReviewSummary(missedTopics),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text('Could not load review summary.');
                  }
                  return Text(
                    snapshot.data ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizHomePage()),
                  );
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
