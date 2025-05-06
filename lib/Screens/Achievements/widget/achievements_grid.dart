import 'package:flutter/material.dart';
import 'package:fintech/Screens/Achievements/widget/achievement_card.dart'; // New component we'll create

class AchievementsList extends StatelessWidget {
  const AchievementsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const SizedBox(height: 20),
          const AchievementCard(
            title: "Bookworm",
            description: "Complete 20 lessons",
            initialState: AchievementState.claimed,
            icon: Icons.menu_book,
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          const AchievementCard(
            title: "Fast Learner",
            description: "Complete 5 lessons in one day",
            initialState: AchievementState.toClaim,
            icon: Icons.flash_on,
            color: Colors.orange,
          ),
          const SizedBox(height: 20),
          const AchievementCard(
            title: "Quiz Master",
            description: "Score 100% on 3 quizzes",
            initialState: AchievementState.locked,
            icon: Icons.quiz,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}