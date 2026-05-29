import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player/player_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F16),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 32),
                  _buildDailyListening(),
                  const SizedBox(height: 32),
                  _buildGenreMix(),
                  const SizedBox(height: 32),
                  _buildMoodProfile(),
                  const SizedBox(height: 100), // Space for mini player
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0F0F16),
      floating: true,
      centerTitle: false,
      title: const Text(
        'Your Insights',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.3)),
          ),
          child: const Text(
            'This Week',
            style: TextStyle(color: Color(0xFF1DB954), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'label': 'Tracks Played', 'val': '127', 'icon': Icons.headphones},
      {'label': 'Total Hours', 'val': '14.5', 'icon': Icons.access_time},
      {'label': 'Artists', 'val': '34', 'icon': Icons.person},
      {'label': 'Daily Avg', 'val': '2.1h', 'icon': Icons.today},
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final item = stats[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, size: 20, color: const Color(0xFF1DB954)),
              const Spacer(),
              Text(item['val'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(item['label'] as String, style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyListening() {
    final hours = [1.2, 2.4, 0.8, 3.1, 2.7, 4.5, 1.8];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const maxH = 4.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Listening', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = hours[i];
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${h}h', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: (h / maxH) * 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954),
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [const Color(0xFF1DB954), const Color(0xFF1DB954).withOpacity(0.5)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(days[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreMix() {
    final genres = [
      {'genre': 'Hip-Hop', 'pct': 45, 'color': const Color(0xFF9B59B6)},
      {'genre': 'R&B/Soul', 'pct': 25, 'color': const Color(0xFF3498DB)},
      {'genre': 'Pop', 'pct': 15, 'color': const Color(0xFFE74C3C)},
      {'genre': 'Electronic', 'pct': 10, 'color': const Color(0xFF1ABC9C)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Genre Mix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 12,
            child: Row(
              children: genres.map((g) => Expanded(
                flex: g['pct'] as int,
                child: Container(color: g['color'] as Color),
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: genres.map((g) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: g['color'] as Color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(g['genre'] as String, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(width: 4),
              Text('${g['pct']}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodProfile() {
    final moods = [
      {'mood': '😤 Hype', 'pct': 38},
      {'mood': '😌 Chill', 'pct': 28},
      {'mood': '😢 Sad', 'pct': 18},
      {'mood': '💪 Focus', 'pct': 16},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mood Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...moods.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m['mood'] as String, style: const TextStyle(fontSize: 14)),
                  Text('${m['pct']}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(3)),
                  ),
                  FractionallySizedBox(
                    widthFactor: (m['pct'] as int) / 100,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF1DB954).withOpacity(0.3), blurRadius: 4, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}