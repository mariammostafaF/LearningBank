import 'package:fintech/Screens/Store/Avatar.dart';
import 'package:fintech/Screens/Store/LessonsStore.dart';
import 'package:fintech/Screens/Store/Voucher.dart';
import 'package:fintech/preferences.dart';
import 'package:flutter/material.dart';

class StoreScreen extends StatefulWidget {
  final String userId; // Add userId parameter
  final int initialCoins;
  final int initialPoints;
  final Function(int) onCoinsUpdate;
  final Function(int) onPointsUpdate;
  final Function(String) onAvatarChanged; // Add this callback

  const StoreScreen({
    Key? key,
    required this.userId,
    required this.initialCoins,
    required this.initialPoints,
    required this.onCoinsUpdate,
    required this.onPointsUpdate,
    required this.onAvatarChanged,
    // Add this parameter
  }) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late int _coins;
  late int _points;

  @override
  void initState() {
    super.initState();
    _coins = widget.initialCoins;
    _points = widget.initialPoints;
  }

  Future<void> _loadUserData() async {
    // Load user-specific coins
    final userCoins = await QuizPreferences.getCoins(widget.userId);
    setState(() {
      _coins = userCoins ?? widget.initialCoins;
      _points = widget.initialPoints;
    });
  }

  Future<void> _loadCoins() async {
    final coins = await QuizPreferences.getCoins(widget.userId);
    setState(() {
      _coins = coins ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFAF1E6);
    const headerColor = Color(0xFFFCDA9C);
    const accentColor = Color(0xFF5D3A00);

    TextStyle tabTextStyle = const TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: 10,
      color: Colors.black,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: headerColor,
          elevation: 4,
          iconTheme: const IconThemeData(color: Colors.black),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              'Store',
              key: const ValueKey('StoreTitle'),
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          bottom: TabBar(
            indicator: RetroTabIndicator(color: accentColor),
            labelColor: accentColor,
            unselectedLabelColor: Colors.black54,
            labelStyle: tabTextStyle,
            tabs: const [
              Tab(icon: Icon(Icons.face), text: 'Avatars'),
              Tab(icon: Icon(Icons.menu_book), text: 'Lessons'),
              Tab(icon: Icon(Icons.card_giftcard), text: 'Vouchers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AvatarsScreen(
              userId: widget.userId,
              initialCoins: _coins,
              initialPoints: _points,
              onCoinsUpdate: (newCoins) async {
                await QuizPreferences.saveCoins(widget.userId, newCoins);
                setState(() => _coins = newCoins);
                widget.onCoinsUpdate(newCoins);
              },
              onPointsUpdate: (newPoints) {
                setState(() {
                  _points = newPoints;
                });
                widget.onPointsUpdate(newPoints); // Propagate the update
              },
              onAvatarChanged: widget.onAvatarChanged, // Pass the callback
            ),
            LessonsStoreTab(
              userId: widget.userId, // Pass the userId
              initialCoins: _coins,
              onCoinsUpdate: (newCoins) async {
                await QuizPreferences.saveCoins(widget.userId, newCoins);
                setState(() => _coins = newCoins);
                widget.onCoinsUpdate(newCoins);
              },
            ),
            VouchersScreen(
              userId: widget.userId, // Pass the userId
              initialCoins: _coins,
              initialPoints: _points,
              onCoinsUpdate: (newCoins) async {
                await QuizPreferences.saveCoins(widget.userId, newCoins);
                setState(() => _coins = newCoins);
                widget.onCoinsUpdate(newCoins);
              },
              onPointsUpdate: (newPoints) {
                setState(() => _points = newPoints);
                widget.onPointsUpdate(newPoints);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RetroTabIndicator extends Decoration {
  final Color color;

  const RetroTabIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RetroPainter(color);
  }
}

class _RetroPainter extends BoxPainter {
  final Color color;
  _RetroPainter(this.color);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final Rect rect =
        Offset(offset.dx, configuration.size!.height - 4) &
        Size(configuration.size!.width, 4);

    canvas.drawRect(rect, paint);
  }
}
