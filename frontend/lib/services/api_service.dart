import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/habit_quest.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<List<HabitQuest>> generateWeeklyQuests({
    required int ghqScore,
    required Map<String, dynamic> ghqAnswers,
    String language = 'English',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-quests'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'ghq_score': ghqScore,
        'ghq_answers': ghqAnswers,
        'language': language,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to generate quests: '
        '${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    final rawQuests = data['weekly_quests'] as List<dynamic>? ?? [];

    return rawQuests.asMap().entries.map(
      (entry) {
        final questMap = Map<String, dynamic>.from(
          entry.value as Map,
        );

        return HabitQuest.fromGemini(
          questMap,
          entry.key,
        );
      },
    ).toList();
  }
}
