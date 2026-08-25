import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ===========================================================
// Mood Options
// The vocabulary used by the emotional check-in.
//
// Valence runs from -2 to 2. A small whole number is easy to
// store, average, and chart.
// ===========================================================

const int minValence = -2;
const int maxValence = 2;

// ===========================================================
// Valence Label
// ===========================================================
String valenceLabel(int valence) {
  return switch (valence) {
    -2 => 'Very Unpleasant',
    -1 => 'Unpleasant',
    0 => 'Neutral',
    1 => 'Pleasant',
    _ => 'Very Pleasant',
  };
}

// ===========================================================
// Valence Colour
// ===========================================================
Color valenceColor(int valence) {
  return switch (valence) {
    -2 => AppColors.blue100,
    -1 => AppColors.blue60,
    0 => AppColors.yellow60,
    1 => AppColors.green60,
    _ => AppColors.green100,
  };
}

// ===========================================================
// Quick Moods
// The four shortcuts on the Home screen. Each opens the rest
// of the card with a starting point already chosen.
// ===========================================================
class QuickMood {
  const QuickMood({
    required this.label,
    required this.icon,
    required this.valence,
    this.emotion,
  });

  final String label;
  final IconData icon;
  final int valence;

  // Preselected in the emotion list when it is not null.
  final String? emotion;
}

const List<QuickMood> quickMoods = [
  QuickMood(
    label: 'Happy',
    icon: Icons.sentiment_very_satisfied_outlined,
    valence: 2,
    emotion: 'Happy',
  ),
  QuickMood(
    label: 'Okay',
    icon: Icons.sentiment_neutral_outlined,
    valence: 0,
  ),
  QuickMood(
    label: 'Low',
    icon: Icons.sentiment_dissatisfied_outlined,
    valence: -1,
    emotion: 'Sad',
  ),
  QuickMood(
    label: 'Stressed',
    icon: Icons.bolt_outlined,
    valence: -1,
    emotion: 'Stressed',
  ),
];

// ===========================================================
// Emotion Words
// Offered in three bands so the list stays short and matches
// where the user placed the slider.
// ===========================================================
const List<String> unpleasantEmotions = [
  'Angry',
  'Anxious',
  'Scared',
  'Overwhelmed',
  'Ashamed',
  'Embarrassed',
  'Frustrated',
  'Annoyed',
  'Stressed',
  'Worried',
  'Guilty',
  'Hopeless',
  'Irritated',
  'Lonely',
  'Discouraged',
  'Disappointed',
  'Drained',
  'Sad',
];

const List<String> neutralEmotions = [
  'Calm',
  'Steady',
  'Quiet',
  'Indifferent',
  'Tired',
  'Distracted',
  'Restless',
  'Curious',
  'Reflective',
  'Surprised',
];

const List<String> pleasantEmotions = [
  'Happy',
  'Grateful',
  'Content',
  'Excited',
  'Proud',
  'Relieved',
  'Confident',
  'Hopeful',
  'Peaceful',
  'Amused',
  'Energised',
  'Satisfied',
  'Loved',
  'Focused',
];

// ===========================================================
// Emotions For Valence
// ===========================================================
List<String> emotionsForValence(int valence) {
  if (valence < 0) return unpleasantEmotions;
  if (valence == 0) return neutralEmotions;

  return pleasantEmotions;
}

// ===========================================================
// Impact Areas
// Grouped so a long list stays easy to scan.
// ===========================================================
class ImpactGroup {
  const ImpactGroup({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}

const List<ImpactGroup> impactGroups = [
  ImpactGroup(
    title: 'You',
    items: [
      'Health',
      'Fitness',
      'Self-Care',
      'Hobbies',
      'Identity',
      'Spirituality',
    ],
  ),
  ImpactGroup(
    title: 'People',
    items: [
      'Family',
      'Friends',
      'Partner',
      'Community',
    ],
  ),
  ImpactGroup(
    title: 'Daily Life',
    items: [
      'Work',
      'Education',
      'Tasks',
      'Money',
      'Travel',
      'Current Events',
      'Weather',
    ],
  ),
];


// ===========================================================
// Journal Prompts
// The questions offered on the Journal screen.
//
// The prompt for a day is chosen from the date, so everyone
// sees a steady prompt that changes at midnight and nothing
// has to be stored to remember which one was shown.
//
// Add prompts freely. Do not reorder or delete existing ones
// if you want past entries to keep matching their prompt id.
// ===========================================================
// ===========================================================
class JournalPrompt {
  const JournalPrompt({
    required this.id,
    required this.text,
    required this.category,
  });

  final String id;
  final String text;
  final String category;
}

const List<JournalPrompt> journalPrompts = [
  JournalPrompt(
    id: 'p01',
    text: 'What took up the most space in your mind today?',
    category: 'Reflection',
  ),
  JournalPrompt(
    id: 'p02',
    text: 'Name one thing that went better than you expected.',
    category: 'Gratitude',
  ),
  JournalPrompt(
    id: 'p03',
    text: 'What drained your energy today, and what restored it?',
    category: 'Energy',
  ),
  JournalPrompt(
    id: 'p04',
    text: 'Write about something you handled well this week.',
    category: 'Strengths',
  ),
  JournalPrompt(
    id: 'p05',
    text: 'What would you tell a friend who had your day?',
    category: 'Perspective',
  ),
  JournalPrompt(
    id: 'p06',
    text: 'What is one small thing you are looking forward to?',
    category: 'Hope',
  ),
  JournalPrompt(
    id: 'p07',
    text: 'Where did you feel most like yourself today?',
    category: 'Reflection',
  ),
  JournalPrompt(
    id: 'p08',
    text: 'What has been sitting unsaid lately?',
    category: 'Honesty',
  ),
  JournalPrompt(
    id: 'p09',
    text: 'Describe a moment today when you felt calm.',
    category: 'Calm',
  ),
  JournalPrompt(
    id: 'p10',
    text: 'What is one thing you would like to let go of?',
    category: 'Release',
  ),
  JournalPrompt(
    id: 'p11',
    text: 'Who made your day easier, and how?',
    category: 'Connection',
  ),
  JournalPrompt(
    id: 'p12',
    text: 'What does rest look like for you right now?',
    category: 'Rest',
  ),
  JournalPrompt(
    id: 'p13',
    text: 'What are you carrying that is not yours to carry?',
    category: 'Boundaries',
  ),
  JournalPrompt(
    id: 'p14',
    text: 'Write about a change you have noticed in yourself.',
    category: 'Growth',
  ),
];

// ===========================================================
// Prompt For Date
// Picks a prompt from the day of the year, so the same day
// always shows the same question.
// ===========================================================
JournalPrompt promptForDate(DateTime date) {
  final startOfYear = DateTime(date.year);
  final dayOfYear = date.difference(startOfYear).inDays;

  return journalPrompts[dayOfYear % journalPrompts.length];
}

// ===========================================================
// Prompt Lookup
// Returns null for unknown ids, which can happen if a prompt
// was removed after an entry was written.
// ===========================================================
JournalPrompt? promptForId(String id) {
  for (final prompt in journalPrompts) {
    if (prompt.id == id) return prompt;
  }

  return null;
}
