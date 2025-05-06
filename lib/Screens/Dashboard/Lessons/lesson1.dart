import 'package:fintech/Screens/Quiz/quiz_list_screen.dart';
import 'package:flutter/material.dart';

class BlockchainBasicsLesson extends StatefulWidget {
  const BlockchainBasicsLesson({Key? key}) : super(key: key);

  @override
  State<BlockchainBasicsLesson> createState() => _BlockchainBasicsLessonState();
}

class _BlockchainBasicsLessonState extends State<BlockchainBasicsLesson> {
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final List<LessonPage> _lessonPages = [
    LessonPage(
      title: 'What is Blockchain?',
      content: '''
Imagine a digital notebook that everyone can see, but no one can erase or cheat in. That's blockchain!

• It's like a chain of digital blocks
• Each block records transactions
• Everyone gets a copy of the notebook
• No single person controls it''',
      image: 'Assets/Images/blockchain1.png',
      color: Colors.blue.shade100,
      bulletIcon: Icons.link,
    ),
    LessonPage(
      title: 'How It Works',
      content: '''
1. Someone makes a transaction (like sending digital money)
2. Computers (called miners) check if it's valid
3. Approved transactions go in a block
4. Blocks link together in order
5. Everyone updates their notebook''',
      image: 'Assets/Images/blockchain2.png',
      color: Colors.green.shade100,
      bulletIcon: Icons.settings,
    ),
    LessonPage(
      title: 'Why It\'s Cool',
      content: '''
✓ No banks needed - people trade directly
✓ Super secure - hard to hack
✓ Transparent - everyone can see
✓ Permanent - can't change past records
✓ Fast - works 24/7 around the world''',
      image: 'Assets/Images/blockchain3.png',
      color: Colors.orange.shade100,
      bulletIcon: Icons.star,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeLesson() {
    // Navigate to QuizListScreen and pass the quiz identifier
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizListScreen(
              autoStartQuizId:
                  'blockchain_basics', // Use a string that identifies the quiz
              userId: 'user200', // Replace with the actual user ID
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF1E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCDA9C),
        elevation: 4,
        title: const Text(
          'Blockchain Basics',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / _lessonPages.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            minHeight: 6,
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _lessonPages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }
                    return Transform.scale(
                      scale: Curves.easeOut.transform(value),
                      child: child,
                    );
                  },
                  child: LessonPageCard(
                    page: _lessonPages[index],
                    isFirst: index == 0,
                    isLast: index == _lessonPages.length - 1,
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  opacity: _currentPage > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    style: _navButtonStyle(Colors.orange.shade100),
                    onPressed:
                        _currentPage > 0
                            ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            )
                            : null,
                    child: const Text(
                      '← Previous',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                if (_currentPage < _lessonPages.length - 1)
                  ElevatedButton(
                    style: _navButtonStyle(Colors.orange.shade100),
                    onPressed:
                        () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        ),
                    child: const Text(
                      'Next →',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    style: _navButtonStyle(
                      Colors.green.shade200,
                    ).copyWith(elevation: MaterialStateProperty.all(4)),
                    onPressed: _completeLesson,
                    child: const Text(
                      'TAKE QUIZ!',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _navButtonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class LessonPage {
  final String title;
  final String content;
  final String image;
  final Color color;
  final IconData bulletIcon;

  const LessonPage({
    required this.title,
    required this.content,
    required this.image,
    required this.color,
    required this.bulletIcon,
  });
}

class LessonPageCard extends StatelessWidget {
  final LessonPage page;
  final bool isFirst;
  final bool isLast;

  const LessonPageCard({
    Key? key,
    required this.page,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 20 : 0,
        right: isLast ? 20 : 0,
        top: 20,
        bottom: 40,
      ),
      child: PhysicalModel(
        color: page.color,
        elevation: 8,
        shadowColor: Colors.black,
        borderRadius: _borderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: page.color,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: _borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildImage(),
                        const SizedBox(height: 20),
                        _buildContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          page.image,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                      Text(
                        'Lesson Image',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final lines = page.content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          lines.map((line) {
            if (line.trim().isEmpty) return const SizedBox(height: 8);

            final isBullet = line.startsWith(RegExp(r'[•✓]|[\d]\.'));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child:
                  isBullet
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            page.bulletIcon,
                            size: 16,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              line.substring(1).trim(),
                              style: const TextStyle(
                                fontFamily: 'PressStart2P',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                      : Text(
                        line,
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                        ),
                      ),
            );
          }).toList(),
    );
  }

  BorderRadius get _borderRadius => BorderRadius.only(
    topLeft: const Radius.circular(4),
    bottomLeft: const Radius.circular(4),
    topRight: Radius.circular(isLast ? 4 : 0),
    bottomRight: Radius.circular(isLast ? 4 : 0),
  );
}
