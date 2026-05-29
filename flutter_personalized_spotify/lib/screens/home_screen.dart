import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player/player_provider.dart';
import '../models/track.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F16),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionHeader('Recently Played', onSeeAll: () {}),
                  _buildHorizontalList(player, sampleTracks),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Personalized for You'),
                  _buildMixGrid(player),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Your Top Artists'),
                  _buildArtistList(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Quick Picks'),
                  _buildQuickPicks(player),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: const Color(0xFF0F0F16),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1DB954).withOpacity(0.3),
                const Color(0xFF0F0F16),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Good morning', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('Welcome back, Nikhil!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF1DB954),
                    child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(PlayerProvider player, List<Track> tracks) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          final t = tracks[i];
          final isActive = player.currentTrack?.id == t.id;
          return GestureDetector(
            onTap: () => player.playTrack(t, tracks),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            image: t.coverUrl != null
                                ? DecorationImage(image: NetworkImage(t.coverUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                        ),
                      ),
                      if (isActive && player.isPlaying)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: Icon(Icons.play_arrow, color: Color(0xFF1DB954), size: 32)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(t.artist, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMixGrid(PlayerProvider player) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, i) {
        final titles = ['Daily Mix 1', 'Fresh Finds', 'Release Radar', 'Chill Hits'];
        final descs = ['The Weeknd, Drake...', 'New music just for you', 'Latest releases', 'Easy vibes'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(Icons.queue_music, size: 48, color: Colors.white.withOpacity(0.2))),
              ),
            ),
            const SizedBox(height: 8),
            Text(titles[i], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(descs[i], style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1),
          ],
        );
      },
    );
  }

  Widget _buildArtistList() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, i) {
          final names = ['Kendrick', 'Drake', 'SZA', 'The Weeknd', 'Dua Lipa'];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white12,
                ),
                const SizedBox(height: 8),
                Text(names[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickPicks(PlayerProvider player) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, i) {
        final t = sampleTracks[i];
        return ListTile(
          onTap: () => player.playTrack(t),
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
              image: t.coverUrl != null
                  ? DecorationImage(image: NetworkImage(t.coverUrl!), fit: BoxFit.cover)
                  : null,
            ),
          ),
          title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(t.artist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          trailing: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
        );
      },
    );
  }
}