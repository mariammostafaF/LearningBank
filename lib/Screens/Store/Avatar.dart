import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintech/Screens/BuyCoinsScreen/buycoins.dart';

class AvatarsScreen extends StatefulWidget {
  final int initialCoins;
  final int initialPoints;
  final Function(int) onCoinsUpdate;
  final Function(int) onPointsUpdate;
  final String userId; // Unique identifier for the user
  final Function(String) onAvatarChanged;

  const AvatarsScreen({
    Key? key,
    required this.initialCoins,
    required this.initialPoints,
    required this.onCoinsUpdate,
    required this.onPointsUpdate,
    required this.userId,
    required this.onAvatarChanged,
  }) : super(key: key);

  @override
  State<AvatarsScreen> createState() => _AvatarsScreenState();
}

class _AvatarsScreenState extends State<AvatarsScreen> {
  late int _coins;
  late int _points;
  Set<String> _purchasedAvatars = {}; // Tracks purchased avatars for the user
  String? _avatarInUse; // Currently selected avatar for the user

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _points = widget.initialPoints;
    _loadAvatarData(); // Load user-specific avatar data
  }

  // Load purchased avatars and selected avatar for the current user
  Future<void> _loadAvatarData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _purchasedAvatars = Set.from(
        prefs.getStringList('purchased_avatars_${widget.userId}') ?? [],
      );
      _avatarInUse = prefs.getString('avatar_in_use_${widget.userId}');
    });
  }

  // Save purchased avatars and selected avatar for the current user
  Future<void> _saveAvatarData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'purchased_avatars_${widget.userId}',
      _purchasedAvatars.toList(),
    );
    if (_avatarInUse != null) {
      await prefs.setString('avatar_in_use_${widget.userId}', _avatarInUse!);
    }
  }

  // Buy an avatar with coins (user-specific)
  Future<void> _buyWithCoins(int coinCost, String avatarId) async {
    if (_coins >= coinCost) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _coins -= coinCost;
        _purchasedAvatars.add(avatarId);
      });
      widget.onCoinsUpdate(_coins);
      await prefs.setInt(
        'total_coins_${widget.userId}',
        _coins,
      ); // Save coins per user
      await _saveAvatarData(); // Save avatars per user
    } else {
      _showNotEnoughCoinsDialog();
    }
  }

  // Show "Not Enough Coins" dialog
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
                            onCoinsUpdate: (updatedCoins) {
                              setState(() {
                                _coins = updatedCoins;
                              });
                            },
                            userId: widget.userId,
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

  // Set the current avatar in use (user-specific)
  Future<void> _setAvatarInUse(String avatarId) async {
    if (!_purchasedAvatars.contains(avatarId)) return;

    setState(() {
      _avatarInUse = avatarId;
    });

    // Call the callback to notify dashboard
    widget.onAvatarChanged(avatarId);

    await _saveAvatarData();
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFFFFF7EC);

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('Assets/Images/star.png', height: 18),
                  const SizedBox(width: 4),
                  Text(
                    "Points: $_points",
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset('Assets/Images/coin.png', width: 18, height: 18),
                  const SizedBox(width: 4),
                  Text(
                    "Coins: $_coins",
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              AvatarCard(
                title: 'Flower Girl',
                avatarId: 'flower_girl', // Unique identifier for each avatar
                costText: '10 coins',
                imagePath: 'Assets/Images/avatar.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('flower_girl'),
                isInUse: _avatarInUse == 'flower_girl',
                onBuy: () => _buyWithCoins(10, 'flower_girl'),
                onUse: () => _setAvatarInUse('flower_girl'),
              ),
              AvatarCard(
                title: 'Mystic Elf',
                avatarId: 'mystic_elf',
                costText: '20 coins',
                imagePath: 'Assets/Images/avatar1.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('mystic_elf'),
                isInUse: _avatarInUse == 'mystic_elf',
                onBuy: () => _buyWithCoins(20, 'mystic_elf'),
                onUse: () => _setAvatarInUse('mystic_elf'),
              ),
              AvatarCard(
                title: 'Techie Tina',
                avatarId: 'techie tina',
                costText: '40 coins',
                imagePath: 'Assets/Images/avatar2.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('techie tina'),
                isInUse: _avatarInUse == 'techie tina',
                onBuy: () => _buyWithCoins(40, 'techie tina'),
                onUse: () => _setAvatarInUse('techie tina'),
              ),
              AvatarCard(
                title: 'Bun Girl',
                avatarId: 'bun girl',
                costText: '60 coins',
                imagePath: 'Assets/Images/avatar3.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('bun girl'),
                isInUse: _avatarInUse == 'bun girl',
                onBuy: () => _buyWithCoins(60, 'bun girl'),
                onUse: () => _setAvatarInUse('bun girl'),
              ),
              AvatarCard(
                title: 'Arcane Master',
                avatarId: 'arcane master',
                costText: '80 coins',
                imagePath: 'Assets/Images/avatar4.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('arcane master'),
                isInUse: _avatarInUse == 'arcane master',
                onBuy: () => _buyWithCoins(80, 'arcane master'),
                onUse: () => _setAvatarInUse('arcane master'),
              ),
              AvatarCard(
                title: 'Sunny Boy',
                avatarId: 'sunny boy',
                costText: '110 coins',
                imagePath: 'Assets/Images/avatar5.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('sunny boy'),
                isInUse: _avatarInUse == 'sunny boy',
                onBuy: () => _buyWithCoins(110, 'sunny boy'),
                onUse: () => _setAvatarInUse('sunny boy'),
              ),
              AvatarCard(
                title: 'Cool Boy',
                avatarId: 'cool boy',
                costText: '150 coins',
                imagePath: 'Assets/Images/avatar6.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('cool boy'),
                isInUse: _avatarInUse == 'cool boy',
                onBuy: () => _buyWithCoins(150, 'cool boy'),
                onUse: () => _setAvatarInUse('cool boy'),
              ),
              AvatarCard(
                title: 'Beard Bro',
                avatarId: 'beard bro',
                costText: '180 coins',
                imagePath: 'Assets/Images/avatar7.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('beard bro'),
                isInUse: _avatarInUse == 'beard bro',
                onBuy: () => _buyWithCoins(180, 'beard bro'),
                onUse: () => _setAvatarInUse('beard bro'),
              ),
              AvatarCard(
                title: 'Sharp Jack',
                avatarId: 'sharp jack',
                costText: '200 coins',
                imagePath: 'Assets/Images/avatar8.png',
                color: Colors.orange.shade100,
                isPurchased: _purchasedAvatars.contains('sharp jack'),
                isInUse: _avatarInUse == 'sharp jack',
                onBuy: () => _buyWithCoins(200, 'sharp jack'),
                onUse: () => _setAvatarInUse('sharp jack'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // AvatarCard Widget (unchanged)
  Widget AvatarCard({
    required String title,
    required String avatarId,
    required String costText,
    required String imagePath,
    required Color color,
    required bool isPurchased,
    required bool isInUse,
    required VoidCallback onBuy,
    required VoidCallback onUse,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            costText,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 7,
              color: Colors.black87,
            ),
          ),
          if (!isPurchased)
            ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade100,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              child: const Text(
                'BUY',
                style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
              ),
            ),
          if (isPurchased && !isInUse)
            ElevatedButton(
              onPressed: onUse,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              child: const Text(
                'USE',
                style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
              ),
            ),
          if (isInUse)
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              child: const Text(
                'IN USE',
                style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
