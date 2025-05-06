import 'package:fintech/Screens/BuyCoinsScreen/buycoins.dart';
import 'package:fintech/Screens/Dashboard/Lessons/lesson1.dart';
import 'package:fintech/preferences.dart';
import 'package:flutter/material.dart';

class LessonsScreen extends StatefulWidget {
  final bool isStoreMode; // NEW: Control purchase behavior
  final int initialCoins; // NEW: Track coins
  final Function(int)? onCoinsUpdate; // NEW: Update coins callback
  final String userId;
  final List<String>? ownedLessonIds;

  const LessonsScreen({
    Key? key,
    this.isStoreMode = false,
    this.initialCoins = 0,
    this.onCoinsUpdate,
    required this.userId,
    this.ownedLessonIds,
  }) : super(key: key);

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _loadPurchasedLessons(); // Load purchased lessons first
  }

  final List<Map<String, dynamic>> _allLessons = [
    {
      'id': 'blockchain_basics',
      'title': 'Blockchain Basics',
      'description': 'Learn the fundamentals of blockchain technology',
      'price': 300,
      'imagePath': 'Assets/Images/digitalpayments.jpeg',
      'color': Colors.blue.shade100,
      'content': 'Detailed explanation of decentralized ledgers...',
    },
    {
      'id': 'Digital_Payments',
      'title': 'Digital Payments',
      'description': 'How modern payment systems work',
      'price': 15,
      'imagePath': 'Assets/Images/digitalpayments.jpeg',
      'color': Colors.green.shade100,
      'content': 'From credit cards to mobile wallets...',
    },
    {
      'id': 'Crypto_Investing',
      'title': 'Crypto Investing',
      'description': 'Strategies for cryptocurrency portfolios',
      'price': 35,
      'imagePath': 'Assets/Images/digitalpayments.jpeg',
      'color': Colors.orange.shade100,
      'content': 'Risk management and market analysis...',
    },
    {
      'id': 'RegTech',
      'title': 'RegTech',
      'description': 'Technology in financial regulation',
      'price': 20,
      'imagePath': 'Assets/Images/digitalpayments.jpeg',
      'color': Colors.purple.shade100,
      'content': 'Compliance automation tools...',
    },
    {
      'id': 'AI_in_Finance',
      'title': 'AI in Finance',
      'description': 'Machine learning applications',
      'price': 30,
      'imagePath': 'Assets/Images/digitalpayments.jpeg',
      'color': Colors.red.shade100,
      'content': 'Algorithmic trading and fraud detection...',
    },
  ];

  List<Map<String, dynamic>> _filteredLessons = [];

  late int _coins;
  List<String> _purchasedLessonIds = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isLoading = true;

  Future<void> _loadPurchasedLessons() async {
    setState(() => _isLoading = true);
    try {
      final purchased = await Preferences.getPurchasedLessons(widget.userId);
      if (mounted) {
        setState(() {
          _purchasedLessonIds = purchased;
          // Always filter based on purchased lessons when not in store mode
          _filteredLessons =
              widget.isStoreMode
                  ? List.from(_allLessons)
                  : _allLessons
                      .where((lesson) => purchased.contains(lesson['id']))
                      .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading purchased lessons: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _searchLessons(String query) {
    final sourceList =
        widget.isStoreMode
            ? _allLessons
            : _allLessons
                .where((l) => _purchasedLessonIds.contains(l['id']))
                .toList();

    setState(() {
      _filteredLessons =
          sourceList.where((lesson) {
            final title = lesson['title'].toLowerCase();
            final desc = lesson['description'].toLowerCase();
            return title.contains(query.toLowerCase()) ||
                desc.contains(query.toLowerCase());
          }).toList();
    });
  }

  final Map<String, Widget Function()> _specialLessons = {
    'blockchain_basics': () => const BlockchainBasicsLesson(),
    // Add other special lessons here
  };

  void _handleLessonTap(Map<String, dynamic> lesson) {
    if (widget.isStoreMode) {
      // Existing purchase logic
      if (_purchasedLessonIds.contains(lesson['id'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You already own "${lesson['title']}"!'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        _purchaseLesson(lesson);
      }
    } else {
      // Navigation logic with special lessons handling
      final lessonId = lesson['id'];

      if (_specialLessons.containsKey(lessonId)) {
        // Navigate to special lesson screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _specialLessons[lessonId]!()),
        );
      } else {
        // Default lesson detail screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
        );
      }
    }
  }

  Future<void> _purchaseLesson(Map<String, dynamic> lesson) async {
    try {
      final price = lesson['price'] as int;
      if (_coins >= price) {
        // Save the purchase first
        await Preferences.savePurchasedLesson(widget.userId, lesson['id']);

        // Then update coins
        final newCoins = _coins - price;
        await Preferences.saveCoins(widget.userId, newCoins);

        if (mounted) {
          setState(() {
            _coins = newCoins;
            _purchasedLessonIds.add(lesson['id']);
            // Update filtered lessons based on current mode
            _filteredLessons =
                widget.isStoreMode
                    ? List.from(_allLessons)
                    : _allLessons
                        .where((l) => _purchasedLessonIds.contains(l['id']))
                        .toList();
          });
        }

        widget.onCoinsUpdate?.call(_coins);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully purchased ${lesson['title']}!')),
        );
      } else {
        _showNotEnoughCoinsDialog();
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase: ${e.toString()}')),
      );
    }
  }

  void _showNotEnoughCoinsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Not Enough Coins'),
            content: const Text(
              'Coins are not sufficient. Do you want to buy more coins?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BuyCoinsScreen(
                            userId: widget.userId, // Pass the userId
                            onCoinsUpdate: (updatedCoins) {
                              setState(() => _coins = updatedCoins);
                            },
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade200,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Buy Coins',
                  style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF1E6),
      appBar:
          widget.isStoreMode
              ? null // No appbar in store mode
              : AppBar(
                backgroundColor: const Color(0xFFFAF1E6),
                elevation: 4,
                title: const Text(
                  'FinTech Lessons',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
              ),
      body: Column(
        children: [
          if (widget.isStoreMode)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset('Assets/Images/coin.png', width: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Coins: $_coins',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchLessons,
                decoration: InputDecoration(
                  hintText: 'Search lessons...',
                  hintStyle: const TextStyle(fontFamily: 'PressStart2P'),
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _loadPurchasedLessons,
                      child:
                          _filteredLessons.isEmpty
                              ? const Center(
                                child: Text('No lessons available'),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: _filteredLessons.length,
                                itemBuilder: (context, index) {
                                  final lesson = _filteredLessons[index];
                                  final isPurchased = _purchasedLessonIds
                                      .contains(lesson['id']);
                                  return LessonCard(
                                    title: lesson['title'],
                                    description: lesson['description'],
                                    price: lesson['price'],
                                    imagePath: lesson['imagePath'],
                                    color: lesson['color'],
                                    isStoreMode: widget.isStoreMode,
                                    isPurchased: isPurchased,
                                    onTap: () => _handleLessonTap(lesson),
                                  );
                                },
                              ),
                    ),
          ),
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final int price;
  final String imagePath;
  final Color color;
  final bool isStoreMode;
  final VoidCallback onTap;
  final bool isPurchased;

  const LessonCard({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.color,
    required this.isStoreMode,
    required this.onTap,
    required this.isPurchased,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isPurchased) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You already own "${title}"!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.asset(
                imagePath,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey,
                      child: const Center(child: Icon(Icons.error)),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPurchased && !isStoreMode)
                    const Text(
                      'OWNED',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),

                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$price coins',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isStoreMode)
                        ElevatedButton(
                          onPressed: isPurchased ? null : () => onTap(),
                          child: Text(
                            isPurchased ? 'OWNED' : 'BUY',
                            style: const TextStyle(fontFamily: 'PressStart2P'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPurchased
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for lesson detail screen
class LessonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonDetailScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson['title'])),
      body: Center(child: Text(lesson['content'])),
    );
  }
}
