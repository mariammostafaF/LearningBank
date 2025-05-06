import 'package:flutter/material.dart';
import '../../preferences.dart';
import 'Constants/quiz_colors.dart';
import 'quiz_list_screen.dart';

class FintechQuizScreen extends StatefulWidget {
  final String quizTitle;
  final int totalQuestions;
  final List<Map<String, dynamic>> questions;
  final String userId;

  const FintechQuizScreen({
    Key? key,
    required this.quizTitle,
    required this.totalQuestions,
    required this.questions,
    required this.userId,
  }) : super(key: key);

  @override
  State<FintechQuizScreen> createState() => _FintechQuizScreenState();
}

class _FintechQuizScreenState extends State<FintechQuizScreen> {
  late final List<Map<String, dynamic>> _questions;
  int _currentQuestion = 0;
  String? _selectedOption;
  bool _answered = false;
  int _correctAnswers = 0;
  int _totalCoins = 0;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions;
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coins = await QuizPreferences.getCoins(widget.userId);
    setState(() {
      _totalCoins = coins;
    });
  }

  Future<void> _saveProgress() async {
    await QuizPreferences.saveCoins(widget.userId, _totalCoins); // Pass userId
    await QuizPreferences.saveQuizProgress(
      widget.userId, // Pass userId
      widget.quizTitle,
      _correctAnswers,
      widget.totalQuestions,
    );
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestion++;
      _selectedOption = null;
      _answered = false;
    });
  }

  void _selectOption(String option) {
    if (_answered) return;

    setState(() {
      _selectedOption = option;
      _answered = true;
      if (option == _questions[_currentQuestion]['answer']) {
        _correctAnswers++;
        _totalCoins += 3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestion >= _questions.length) {
      _saveProgress();
      return _buildResultsScreen();
    }
    return _buildQuizScreen();
  }

  Widget _buildResultsScreen() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.quizTitle,
          style: QuizColors.courierText(20, FontWeight.bold),
        ),
        backgroundColor: QuizColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: QuizColors.background,
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [QuizColors.thickShadow],
                ),
                child: Column(
                  children: [
                    Text(
                      '🎉 Quiz Completed!',
                      style: QuizColors.courierText(26, FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Score: $_correctAnswers/${_questions.length}',
                      style: QuizColors.courierText(22),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('Assets/Images/coin.png', width: 30),
                        const SizedBox(width: 8),
                        Text(
                          '$_totalCoins coins earned!',
                          style: QuizColors.courierText(20, FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => QuizListScreen(userId: widget.userId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuizColors.button,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: QuizColors.thickBlackBorder,
                        ),
                      ),
                      child: Text(
                        'BACK TO QUIZZES',
                        style: QuizColors.courierText(16, FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final current = _questions[_currentQuestion];
    return Scaffold(
      backgroundColor: QuizColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.quizTitle,
          style: QuizColors.courierText(20, FontWeight.bold),
        ),
        backgroundColor: QuizColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                Image.asset('Assets/Images/coin.png', width: 25),
                const SizedBox(width: 5),
                Text(
                  '$_totalCoins',
                  style: QuizColors.courierText(16, FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: QuizColors.card,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [QuizColors.thickShadow],
          ),
          child: Column(
            children: [
              Text(
                'Question ${_currentQuestion + 1}/${_questions.length}',
                style: QuizColors.courierText(16, FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      current['question'],
                      textAlign: TextAlign.center,
                      style: QuizColors.courierText(20, FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    ...current['options'].map<Widget>((option) {
                      final isCorrect = option == current['answer'];
                      final isSelected = _selectedOption == option;
                      Color bgColor = QuizColors.background;

                      if (_answered) {
                        if (isSelected) {
                          bgColor =
                              isCorrect
                                  ? QuizColors.correctAnswer
                                  : QuizColors.wrongAnswer;
                        } else if (isCorrect) {
                          bgColor = QuizColors.correctAnswer;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap: () => _selectOption(option),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                option,
                                style: QuizColors.courierText(
                                  16,
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              if (_answered)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QuizColors.button,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: QuizColors.thickBlackBorder,
                      ),
                    ),
                    child: Text(
                      _currentQuestion == _questions.length - 1
                          ? 'FINISH'
                          : 'NEXT',
                      style: QuizColors.courierText(16, FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
