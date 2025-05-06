import 'package:fintech/Screens/Store/Avatar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/progress_circle.dart';
import 'models/section_grid.dart';
import 'models/stat_row.dart';
import 'package:fintech/Screens/profile/profile.dart';
import 'package:fintech/Screens/Login/login_screen.dart';
import 'package:fintech/Screens/Achievements/achievements.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Needed for Firestore

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _levelProgress = 0.0;
  int _currentLevel = 1;

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _userName = data?['name'] ?? 'User';
          _currentLevel = data?['level'] ?? 1;
          _levelProgress = (data?['progress'] ?? 0).toDouble();
          _isLoading = false;
        });
      }
    }
  }

  String? _currentAvatarPath;
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadCurrentAvatar();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? 'User';
        });
      }
    }
  }

  Future<void> _loadCurrentAvatar() async {
    const avatarPaths = {
      'flower_girl': 'Assets/Images/avatar.png',
      'mystic_elf': 'Assets/Images/avatar1.png',
      'techie tina': 'Assets/Images/avatar2.png',
      'bun girl': 'Assets/Images/avatar3.png',
      'arcane master': 'Assets/Images/avatar4.png',
      'sunny boy': 'Assets/Images/avatar5.png',
      'cool boy': 'Assets/Images/avatar6.png',
      'beard bro': 'Assets/Images/avatar7.png',
      'sharp jack': 'Assets/Images/avatar8.png',
    };

    final prefs = await SharedPreferences.getInstance();
    final avatarId = prefs.getString('avatar_in_use_current_user_id');

    if (mounted) {
      setState(() {
        _currentAvatarPath =
            avatarId != null && avatarPaths.containsKey(avatarId)
                ? avatarPaths[avatarId]
                : null;
        _isLoading = false;
      });
    }
  }

  void _updateAvatar(String newAvatarPath) {
    setState(() {
      _currentAvatarPath = newAvatarPath;
    });
  }

  void _handleAvatarChanged(String avatarId) {
    const avatarPaths = {
      'flower_girl': 'Assets/Images/avatar.png',
      'mystic_elf': 'Assets/Images/avatar1.png',
      'techie tina': 'Assets/Images/avatar2.png',
      'bun girl': 'Assets/Images/avatar3.png',
      'arcane master': 'Assets/Images/avatar4.png',
      'sunny boy': 'Assets/Images/avatar5.png',
      'cool boy': 'Assets/Images/avatar6.png',
      'beard bro': 'Assets/Images/avatar7.png',
      'sharp jack': 'Assets/Images/avatar8.png',
    };

    if (avatarPaths.containsKey(avatarId)) {
      setState(() {
        _currentAvatarPath = avatarPaths[avatarId];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 245, 228, 202),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 228, 202),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 228, 202),
        title: Text(
          "Welcome, ${_userName ?? 'User'}!",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
              _currentAvatarPath != null
                  ? CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(_currentAvatarPath!),
                    backgroundColor: Colors.transparent,
                  )
                  : const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: userId),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully")),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                StatRow(userId: userId),
                const SizedBox(height: 30),
                const ProgressCircle(levelProgress: 0.42, currentLevel: 3),
                const SizedBox(height: 30),
                SectionGrid(
                  onAvatarChanged: _handleAvatarChanged,
                  userId: userId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
