import 'package:fintech/Screens/Dashboard/Dashboard.dart';
import 'package:fintech/Screens/Quiz/model/quiz_model.dart';
import 'package:fintech/Screens/Quiz/widget/quiz_card.dart';
import 'package:flutter/material.dart';
import '../../preferences.dart';
import 'model/quiz_questions.dart';
import 'Constants/quiz_colors.dart';
import 'fintech_quiz_screen.dart';

class QuizListScreen extends StatefulWidget {
  final String userId;
  final String? autoStartQuizId;

  const QuizListScreen({
    Key? key,
    this.autoStartQuizId,
    required this.userId, // Require userId
  }) : super(key: key);

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  late List<QuizModel> quizzes;
  bool _isLoading = true;

  @override
  @override
  void initState() {
    super.initState();
    _initQuizzes().then((_) {
      if (widget.autoStartQuizId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startQuizById(widget.autoStartQuizId!);
        });
      }
    });
  }

  void _startQuizById(String quizId) {
    switch (quizId) {
      case 'blockchain_basics':
        _startBlockchainBasicsQuiz();
        break;
      // Add more cases here if needed
      default:
        debugPrint('Unknown quiz ID: $quizId');
    }
  }

  void _startBlockchainBasicsQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FintechQuizScreen(
              userId: widget.userId,
              quizTitle: 'Blockchain Basics',
              totalQuestions:
                  QuizQuestions.getQuestionsForQuiz('Blockchain Basics').length,
              questions: QuizQuestions.getQuestionsForQuiz('Blockchain Basics'),
            ),
      ),
    );
  }

  Future<void> _initQuizzes() async {
    quizzes =
        ["Blockchain Basics", "Fraud Awareness", "Banking Essentials"].map((
          title,
        ) {
          return QuizModel(
            title: title,
            totalQuestions: QuizQuestions.getQuestionsForQuiz(title).length,
            completedPercentage: 0,
            icon: QuizQuestions.getIconForQuiz(title),
          );
        }).toList();

    for (var quiz in quizzes) {
      final progress = await QuizPreferences.getQuizProgress(
        widget.userId,
        quiz.title,
      );
      quiz.completedPercentage = progress['percentage']!;
      quiz.correctAnswers = progress['correct']!;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuizColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
            );
          },
        ),
        title: Text(
          'FinTech Quizzes',
          style: QuizColors.courierText(28, FontWeight.bold),
        ),
        backgroundColor: QuizColors.primary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Test your financial knowledge:",
                      style: QuizColors.courierText(18),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizzes[index];
                          return QuizCard(quiz: quiz, onStartPressed: () {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
