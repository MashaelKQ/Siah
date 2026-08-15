class WellnessQuestion {
  const WellnessQuestion({
    required this.text,
    required this.options,
    required this.scores,
  });

  // ===========================================================
  // Question Content
  // Stores the question displayed to the user.
  // ===========================================================
  final String text;

  // ===========================================================
  // Answer Options
  // Stores the four responses available for the question.
  // ===========================================================
  final List<String> options;

  // ===========================================================
  // Option Scores
  // Maps each response to its GHQ score.
  //
  // GHQ binary scoring:
  // Option 1 = 0
  // Option 2 = 0
  // Option 3 = 1
  // Option 4 = 1
  //
  // Total questionnaire score: 0 to 12.
  // ===========================================================
  final List<int> scores;
}
