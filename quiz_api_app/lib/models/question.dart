class Question {
  final String question;
  final List<String> answers;
  final String correctAnswer;

  Question({
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final questionText = (json['text'] ?? '').toString();

    final rawAnswers = json['answers'];
    if (rawAnswers is! List) {
      throw Exception('Invalid answers format');
    }

    final List<String> answerTexts = [];
    String correct = '';

    for (final item in rawAnswers) {
      if (item is Map<String, dynamic>) {
        final text = (item['text'] ?? '').toString().trim();
        final isCorrect = item['isCorrect'] == true;

        if (text.isNotEmpty) {
          answerTexts.add(text);
        }

        if (isCorrect) {
          correct = text;
        }
      }
    }

    if (questionText.isEmpty || answerTexts.isEmpty || correct.isEmpty) {
      throw Exception('Invalid question data');
    }

    return Question(
      question: questionText,
      answers: answerTexts,
      correctAnswer: correct,
    );
  }
}
