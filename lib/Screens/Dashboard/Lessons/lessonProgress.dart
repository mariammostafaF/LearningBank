// lesson_progress.dart
import 'package:flutter/material.dart ';
import 'package:shared_preferences/shared_preferences.dart';

class LessonProgress {
  static const String _storageKey = 'lesson_progress';
  static const Map<String, int> _lessonRequirements = {
    'Blockchain Basics': 100, // 80 (lesson) + 20 (quiz)
    'Digital Payments': 100,
    'Crypto Investing': 100,
    'RegTech': 100,
    'AI in Finance': 100,
  };

  static Future<void> saveLessonCompletion(
    String lessonName,
    int points,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt('$lessonName-points') ?? 0;
    await prefs.setInt('$lessonName-points', currentPoints + points);
  }

  static Future<bool> isLessonUnlocked(String lessonName) async {
    // First lesson is always unlocked
    if (lessonName == 'Blockchain Basics') return true;

    final prefs = await SharedPreferences.getInstance();
    final previousLesson = _getPreviousLesson(lessonName);

    if (previousLesson == null) return true;

    final points = prefs.getInt('$previousLesson-points') ?? 0;
    return points >= _lessonRequirements[previousLesson]!;
  }

  static String? _getPreviousLesson(String currentLesson) {
    final lessons = _lessonRequirements.keys.toList();
    final currentIndex = lessons.indexOf(currentLesson);
    return currentIndex > 0 ? lessons[currentIndex - 1] : null;
  }
}
