import 'package:flutter/material.dart';

class QuizModel {
  final String title;
  final int totalQuestions;
  int completedPercentage;
  final IconData icon;
  int correctAnswers;

  QuizModel({
    required this.title,
    required this.totalQuestions,
    required this.completedPercentage,
    required this.icon,
    this.correctAnswers = 0,
  });

  QuizModel copyWith({
    String? title,
    int? totalQuestions,
    int? completedPercentage,
    IconData? icon,
    int? correctAnswers,
  }) {
    return QuizModel(
      title: title ?? this.title,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completedPercentage: completedPercentage ?? this.completedPercentage,
      icon: icon ?? this.icon,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }
}
