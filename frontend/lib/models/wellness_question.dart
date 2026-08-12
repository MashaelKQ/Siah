class WellnessQuestion {
  const WellnessQuestion({
    required this.text,
    required this.options,
  });

  // ===========================================================
  // Question Content
  // Stores the text displayed to the user.
  // ===========================================================
  final String text;

  // ===========================================================
  // Answer Options
  // Stores the four responses available for this question.
  // The option index maps to a score from 0 to 3.
  // ===========================================================
  final List<String> options;
}
