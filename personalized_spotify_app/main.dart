import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player/player_provider.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/mini_player.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/now_playing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerProvider(),
      child: MaterialApp(
        title: 'Personalized Spotify',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F16),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1DB954),
            secondary: Color(0xFF1DB954),
          ),
        ),
        home: const RootScreen(),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  static final _pages = <Widget>[
    const HomeScreen(),
    const LibraryScreen(),
    const UploadScreen(),
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openNowPlaying(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(onOpenNowPlaying: () => _openNowPlaying(context)),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        activeIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
