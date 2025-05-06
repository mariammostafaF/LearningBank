import 'package:fintech/Screens/Dashboard/Lessons/lessons.dart';
import 'package:flutter/material.dart';

class LessonsStoreTab extends StatelessWidget {
  final int initialCoins;
  final Function(int) onCoinsUpdate;

  final dynamic userId;

  const LessonsStoreTab({
    Key? key,
    required this.initialCoins,
    required this.onCoinsUpdate,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LessonsScreen(
      isStoreMode: true, // Flag to enable purchases
      initialCoins: initialCoins,
      onCoinsUpdate: onCoinsUpdate,
      userId: userId, // Pass userId to LessonsScreen
    );
  }
}
