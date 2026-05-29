import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: activeIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.white70,
      backgroundColor: const Color(0xFF12121E),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
        BottomNavigationBarItem(icon: Icon(Icons.cloud_upload), label: 'Upload'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Insights'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}