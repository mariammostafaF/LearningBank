import 'package:fintech/Screens/Dashboard/widgets/retroBox.dart';
import 'package:fintech/preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatRow extends StatefulWidget {
  final String userId; // Add userId parameter

  const StatRow({super.key, required this.userId}); // Require userId

  @override
  State<StatRow> createState() => _StatRowState();
}

class _StatRowState extends State<StatRow> {
  int _coins = 100;
  int _points = 50; // If you want to make points dynamic too

  @override
  void initState() {
    super.initState();
    _loadCoins();
    // _loadPoints(); // Uncomment if you want to load points from preferences
  }

  Future<void> _loadCoins() async {
    final coins = await QuizPreferences.getCoins(widget.userId); // Pass userId
    setState(() {
      _coins = coins;
    });
  }

  // Future<void> _loadPoints() async {
  //   // Implement similar logic for points if needed
  // }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: RetroStatBox(
              title: "Points:",
              value: _points.toString(), // Now dynamic
              imagePath: 'Assets/Images/star.png',
              backgroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: RetroStatBox(
              title: "Coins:",
              value: _coins.toString(), // Now dynamic
              imagePath: 'Assets/Images/coin.png',
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
