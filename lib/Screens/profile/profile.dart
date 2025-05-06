// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:fintech/Screens/Dashboard/models/stat_row.dart';
import 'package:fintech/Screens/profile/widgets/progress_circle.dart';
import 'package:fintech/Screens/profile/widgets/achievements_insights.dart';
import 'package:fintech/Screens/profile/widgets/lesson_quizes_stat_row.dart';
import 'package:fintech/Screens/Achievements/achievements.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  const ProfileScreen({
    super.key,
    required this.userId, // Make it required
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 245, 228, 202),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 228, 202),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ProgressCircle(progress: 0.65, level: 7),
                const SizedBox(height: 30),

                // Points & Coins Section
                _buildSectionHeader('Points & Coins'),
                const SizedBox(height: 8),

                StatRow(userId: userId),
                const SizedBox(height: 24),

                // Lessons & Quizzes Section
                _buildSectionHeader('Learning Progress'),
                const SizedBox(height: 8),
                const StatRow2(lessonsCompleted: 12, quizzesCompleted: 8),
                const SizedBox(height: 24),

                // Achievements Insights Section
                AchievementsInsights(
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
