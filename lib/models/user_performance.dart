class UserPerformance {
  int correctStreak = 0;
  int wrongStreak = 0;
  int totalCorrect = 0;
  int totalWrong = 0;
  List<String> missedTopics = [];
  List<int> responseTimes = [];
  String lastCategory = '';

  void recordAnswer({
    required bool correct,
    required String category,
    required int responseTime,
  }) {
    if (correct) {
      correctStreak++;
      wrongStreak = 0;
      totalCorrect++;
    } else {
      wrongStreak++;
      correctStreak = 0;
      totalWrong++;
      missedTopics.add(category);
    }
    responseTimes.add(responseTime);
    lastCategory = category;
  }

  void reset() {
    correctStreak = 0;
    wrongStreak = 0;
    totalCorrect = 0;
    totalWrong = 0;
    missedTopics.clear();
    responseTimes.clear();
    lastCategory = '';
  }
}
