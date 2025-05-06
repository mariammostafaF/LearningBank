import 'package:fintech/Screens/BuyCoinsScreen/buy_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyCoinsScreen extends StatefulWidget {
  final Function(int) onCoinsUpdate;

  const BuyCoinsScreen({
    super.key,
    required this.onCoinsUpdate,
    required String userId,
  });

  @override
  State<BuyCoinsScreen> createState() => _BuyCoinsScreenState();
}

class _BuyCoinsScreenState extends State<BuyCoinsScreen> {
  int _coins = 0;

  Future<void> _buyCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coins += amount;
    });
    await prefs.setInt('total_coins', _coins);
    widget.onCoinsUpdate(_coins);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '+$amount Coins Added!',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'courier',
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.green.shade400,
      ),
    );
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coins = prefs.getInt('total_coins') ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Buy Coins',
          style: TextStyle(fontFamily: 'PressStart2P'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            BuyCard(
              coins: 50,
              price: '\$20',
              title: 'Starter Pack',
              subtitle: 'Great for testing the store experience!',
              onPressed: () => _buyCoins(50),
            ),
            BuyCard(
              coins: 120,
              price: '\$280',
              title: 'Standard Pack',
              subtitle: 'Most popular choice for learners',
              onPressed: () => _buyCoins(120),
            ),
            BuyCard(
              coins: 300,
              price: '\$600',
              title: 'Mega Pack',
              subtitle: 'Unlock quizzes and vouchers faster!',
              onPressed: () => _buyCoins(300),
            ),
            BuyCard(
              coins: 800,
              price: '\$1500',
              title: 'Ultimate Bundle',
              subtitle: 'Everything you’ll ever need!',
              onPressed: () => _buyCoins(800),
            ),
          ],
        ),
      ),
    );
  }
}
