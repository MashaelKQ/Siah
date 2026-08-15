import '../models/wellness_question.dart';

// ===========================================================
// GHQ-12 Wellness Questionnaire
// Uses binary GHQ scoring: 0, 0, 1, 1.
// Maximum total score: 12.
// ===========================================================
const List<WellnessQuestion> wellnessQuestions = [
  WellnessQuestion(
    text: 'Been able to concentrate on what you’re doing?',
    options: [
      'Better than usual',
      'Same as usual',
      'Less than usual',
      'Much less than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text: 'Lost much sleep over worry?',
    options: [
      'Not at all',
      'No more than usual',
      'Rather more than usual',
      'Much more than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text:
        'Felt you were playing a useful part in things, such as daily activities, family and community?',
    options: [
      'More so than usual',
      'Same as usual',
      'Less useful than usual',
      'Much less useful',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text: 'Felt capable of making decisions about things?',
    options: [
      'More so than usual',
      'Same as usual',
      'Less so than usual',
      'Much less capable',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text: 'Felt constantly under strain (pressure/stress)?',
    options: [
      'Not at all',
      'No more than usual',
      'Rather more than usual',
      'Much more than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text: 'Felt you couldn’t overcome your difficulties?',
    options: [
      'Not at all',
      'No more than usual',
      'Rather more than usual',
      'Much more than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text: 'Been able to enjoy your normal day-to-day activities?',
    options: [
      'More so than usual',
      'Same as usual',
      'Less so than usual',
      'Much less than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text: 'Been able to face up to your problems?',
    options: [
      'More so than usual',
      'Same as usual',
      'Less so than usual',
      'Much less able',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text: 'Been feeling unhappy and depressed?',
    options: [
      'Not at all',
      'No more than usual',
      'Rather more than usual',
      'Much more than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text: 'Been losing confidence in yourself?',
    options: [
      'Not at all',
      'No more than usual',
      'Rather more than usual',
      'Much more than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text:
        'Been thinking of yourself as a worthless person (not having value, unimportant)?',
    options: [
      'Not at all',
      'No more than usual',
      'Rather more than usual',
      'Much more than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
  WellnessQuestion(
    text:
        'Been feeling reasonably happy, all things considered? (within past two weeks)',
    options: [
      'More so than usual',
      'Same as usual',
      'Less so than usual',
      'Much less than usual',
    ],
    scores: [0, 0, 1, 1],
  ),
];
