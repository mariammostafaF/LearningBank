import 'package:flutter/material.dart';

enum AchievementState { locked, toClaim, claimed }

class AchievementCard extends StatefulWidget {
  final String title;
  final String description;
  final AchievementState initialState;
  final IconData icon;
  final Color color;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.initialState,
    required this.icon,
    required this.color,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard> {
  late AchievementState _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
  }

  void _handleClaim() {
    if (_currentState != AchievementState.toClaim) return;

    setState(() {
      _currentState = AchievementState.claimed;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Achievement claimed!")));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleClaim,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusBorderColor(),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _currentState == AchievementState.locked
                      ? 'LOCKED'
                      : _currentState == AchievementState.toClaim
                      ? 'CLAIM'
                      : 'CLAIMED',
                  style: TextStyle(
                    color: _getStatusTextColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: CircleAvatar(
                    backgroundColor: _getIconBackgroundColor(),
                    radius: 24,
                    child: Icon(widget.icon, color: _getIconColor(), size: 24),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      if (_currentState != AchievementState.claimed)
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                          child:
                              _currentState == AchievementState.toClaim
                                  ? Container(
                                    width: double.infinity,
                                    color: widget.color.withOpacity(0.3),
                                  )
                                  : null,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_currentState) {
      case AchievementState.locked:
        return Colors.grey[200]!;
      case AchievementState.toClaim:
        return const Color.fromARGB(255, 190, 234, 254).withOpacity(0.8);
      case AchievementState.claimed:
        return Colors.white;
    }
  }

  Color _getIconBackgroundColor() {
    switch (_currentState) {
      case AchievementState.locked:
        return Colors.grey[300]!;
      case AchievementState.toClaim:
        return widget.color.withOpacity(0.3);
      case AchievementState.claimed:
        return widget.color.withOpacity(0.2);
    }
  }

  Color _getIconColor() {
    switch (_currentState) {
      case AchievementState.locked:
        return Colors.grey[600]!;
      case AchievementState.toClaim:
        return widget.color;
      case AchievementState.claimed:
        return widget.color;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (_currentState) {
      case AchievementState.locked:
        return Colors.black;
      case AchievementState.toClaim:
        return widget.color.withOpacity(0.3);
      case AchievementState.claimed:
        return widget.color.withOpacity(0.2);
    }
  }

  Color _getStatusBorderColor() {
    switch (_currentState) {
      case AchievementState.locked:
        return Colors.grey[700]!;
      case AchievementState.toClaim:
        return widget.color;
      case AchievementState.claimed:
        return widget.color;
    }
  }

  Color _getStatusTextColor() {
    switch (_currentState) {
      case AchievementState.locked:
        return Colors.white;
      case AchievementState.toClaim:
        return widget.color;
      case AchievementState.claimed:
        return widget.color;
    }
  }
}
