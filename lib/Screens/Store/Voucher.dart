import 'package:fintech/Screens/BuyCoinsScreen/buycoins.dart';
import 'package:fintech/preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VouchersScreen extends StatefulWidget {
  final int initialCoins;
  final int initialPoints;
  final Function(int) onCoinsUpdate;
  final Function(int) onPointsUpdate;
  final String userId; // Add userId parameter

  const VouchersScreen({
    Key? key,
    required this.initialCoins,
    required this.initialPoints,
    required this.onCoinsUpdate,
    required this.onPointsUpdate,
    required this.userId, // Require userId
  }) : super(key: key);

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  late int _coins;
  late int _points;
  final List<Map<String, dynamic>> _vouchers = [
    {
      'title': '5% Cashback',
      'description': 'Get 5% back on next purchase',
      'cost': 50,
      'icon': Icons.percent,
      'color': Colors.purple.shade100,
      'redeemed': false,
    },
    {
      'title': 'Free Transfer',
      'description': 'Zero fees for 1 transaction',
      'cost': 30,
      'icon': Icons.send,
      'color': Colors.blue.shade100,
      'redeemed': false,
    },
    {
      'title': 'Double Points',
      'description': '2x rewards for 24h',
      'cost': 80,
      'icon': Icons.star,
      'color': Colors.yellow.shade100,
      'redeemed': false,
    },
    {
      'title': 'Discount+',
      'description': '10% off investments',
      'cost': 100,
      'icon': Icons.discount,
      'color': Colors.green.shade100,
      'redeemed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _points = widget.initialPoints;
    _loadRedeemedVouchers();
  }

  Future<void> _loadRedeemedVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    for (var voucher in _vouchers) {
      // User-specific loading
      voucher['redeemed'] =
          prefs.getBool('voucher_${widget.userId}_${voucher['title']}') ??
          false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Coins/Points Header
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
        // Vouchers List - Only show non-redeemed vouchers
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children:
                _vouchers
                    .where((voucher) => !voucher['redeemed'])
                    .map(
                      (voucher) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildVoucherCard(
                          title: voucher['title'],
                          description: voucher['description'],
                          costText: '${voucher['cost']} coins',
                          icon: voucher['icon'],
                          color: voucher['color'],
                          onRedeem:
                              () => _redeemWithCoins(
                                voucher['cost'],
                                voucher['title'],
                              ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherCard({
    required String title,
    required String description,
    required String costText,
    required IconData icon,
    required Color color,
    required VoidCallback onRedeem,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 40, color: Colors.black),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    costText,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 9,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: onRedeem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              child: const Text(
                'REDEEM',
                style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _redeemWithCoins(int coinCost, String voucherTitle) async {
    if (_coins >= coinCost) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _coins -= coinCost;
        _vouchers.firstWhere((v) => v['title'] == voucherTitle)['redeemed'] =
            true;
      });
      widget.onCoinsUpdate(_coins);
      await prefs.setInt('total_coins', _coins);
      // User-specific saving
      await prefs.setBool('voucher_${widget.userId}_$voucherTitle', true);
      _showSuccessDialog(voucherTitle);
    } else {
      _showCoinErrorDialog();
    }
  }

  void _showSuccessDialog(String voucherTitle) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(6, 6)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SUCCESS!',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You redeemed: $voucherTitle',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade200,
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontFamily: 'PressStart2P'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showCoinErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(6, 6)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NOT ENOUGH COINS',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You need more coins to redeem this voucher.',
                    style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BuyCoinsScreen(
                                    onCoinsUpdate: (newCoins) {
                                      setState(() => _coins = newCoins);
                                    },
                                    userId: widget.userId,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade200,
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        child: const Text(
                          'BUY COINS',
                          style: TextStyle(fontFamily: 'PressStart2P'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
