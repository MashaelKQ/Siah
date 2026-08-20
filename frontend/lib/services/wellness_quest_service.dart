import '../models/habit_quest.dart';

class WellnessQuestService {
  const WellnessQuestService._();

  // ===========================================================
  // Generate Weekly Quests
  // Creates personalized weekly quests from GHQ-12 responses.
  // ===========================================================
  static List<HabitQuest> generateWeeklyQuests(
    List<int> answers,
  ) {
    final quests = <HabitQuest>[];

    // Concentration
    if (answers.isNotEmpty && answers[0] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'focus',
          title: 'Focus Session',
          description:
              'Complete one focused task without checking your phone or multitasking.',
          category: 'focus',
          targetCount: 3,
        ),
      );
    }

    // Sleep
    if (answers.length > 1 && answers[1] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'sleep',
          title: 'Screen-Free Bedtime',
          description: 'Avoid screens for 30 minutes before bedtime.',
          category: 'sleep',
          targetCount: 3,
        ),
      );
    }

    // Purpose
    if (answers.length > 2 && answers[2] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'purpose',
          title: 'Meaningful Activity',
          description: 'Spend at least 15 minutes doing something meaningful.',
          category: 'purpose',
          targetCount: 2,
        ),
      );
    }

    // Decision Making
    if (answers.length > 3 && answers[3] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'decision',
          title: 'Make One Small Decision',
          description: 'Complete one small decision you have been delaying.',
          category: 'confidence',
          targetCount: 2,
        ),
      );
    }

    // Stress
    if (answers.length > 4 && answers[4] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'breathing',
          title: 'Breathing Reset',
          description:
              'Spend five minutes practicing slow, controlled breathing.',
          category: 'stress',
          targetCount: 3,
        ),
      );
    }

    // Coping
    if (answers.length > 5 && answers[5] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'problem',
          title: 'Break Down One Challenge',
          description:
              'Write one challenge and one small step you can take today.',
          category: 'coping',
          targetCount: 2,
        ),
      );
    }

    // Enjoyment
    if (answers.length > 6 && answers[6] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'enjoyment',
          title: 'Do Something You Enjoy',
          description: 'Spend at least 20 minutes doing something you enjoy.',
          category: 'enjoyment',
          targetCount: 2,
        ),
      );
    }

    // Facing Problems
    if (answers.length > 7 && answers[7] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'face_problem',
          title: 'Finish One Avoided Task',
          description: 'Complete one small task you have been avoiding.',
          category: 'coping',
          targetCount: 2,
        ),
      );
    }

    // Mood
    if (answers.length > 8 && answers[8] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'journal',
          title: 'Journal Check-In',
          description: 'Spend five minutes writing about how you feel today.',
          category: 'mood',
          targetCount: 3,
        ),
      );
    }

    // Confidence
    if (answers.length > 9 && answers[9] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'confidence',
          title: 'Recognize One Achievement',
          description: 'Write down one thing you handled well today.',
          category: 'confidence',
          targetCount: 3,
        ),
      );
    }

    // Self-Worth
    if (answers.length > 10 && answers[10] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'self_worth',
          title: 'Practice Self-Appreciation',
          description: 'Write down one quality you appreciate about yourself.',
          category: 'self-worth',
          targetCount: 2,
        ),
      );
    }

    // Happiness
    if (answers.length > 11 && answers[11] >= 2) {
      quests.add(
        const HabitQuest(
          id: 'positive_activity',
          title: 'Plan Something Enjoyable',
          description: 'Plan one enjoyable activity for this week.',
          category: 'happiness',
          targetCount: 1,
        ),
      );
    }

    // ===========================================================
    // Default Weekly Plan
    // Used when no significant area is flagged.
    // ===========================================================
    if (quests.isEmpty) {
      quests.addAll(
        const [
          HabitQuest(
            id: 'breathing',
            title: 'Breathing Reset',
            description: 'Spend five minutes practicing slow breathing.',
            category: 'stress',
            targetCount: 2,
          ),
          HabitQuest(
            id: 'journal',
            title: 'Journal Check-In',
            description: 'Write a short reflection about your day.',
            category: 'mood',
            targetCount: 2,
          ),
          HabitQuest(
            id: 'enjoyment',
            title: 'Do Something You Enjoy',
            description:
                'Spend time doing something that supports your wellbeing.',
            category: 'enjoyment',
            targetCount: 1,
          ),
        ],
      );
    }

    return quests.take(4).toList();
  }
}
