import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player/player_provider.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/mini_player.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'screens/now_playing_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://vggrimvjjzwmxvaqsbpb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnZ3JpbXZqanp3bXh2YXFzYnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNDM1NjQsImV4cCI6MjA4OTgxOTU2NH0.yLxpQ_WkckFrNAX7QRncWUfgbIW4RVhMxPF871tw60k',
  );

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
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1DB954),
          scaffoldBackgroundColor: const Color(0xFF0F0F16),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1DB954),
            secondary: Color(0xFF1DB954),
            surface: Color(0xFF0F0F16),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0F0F16),
            selectedItemColor: Color(0xFF1DB954),
            unselectedItemColor: Colors.white70,
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
    const SearchScreen(),
    const LibraryScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openNowPlaying(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
    );
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