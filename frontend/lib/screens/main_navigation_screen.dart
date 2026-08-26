import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import 'wellness_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  // ===========================================================
  // Tab Switching
  // Moves to a tab from inside a screen, so the Journal card on
  // Home can open the Journal tab.
  // ===========================================================
  void _openTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  // Built in build() rather than held as a const list, because
  // HomeScreen now needs a callback into this state.
  List<Widget> get screens => [
        HomeScreen(
          onOpenJournal: () => _openTab(1),
          onOpenWellness: () => _openTab(2),
        ),
        const JournalScreen(),
        const WellnessScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SiahBottomNavBar(
        currentIndex: currentIndex,
        onTap: _openTab,
      ),
    );
  }
}
