import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player/player_provider.dart';
import '../models/track.dart';
import 'upload_screen.dart';
import 'settings_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _search = '';
  String _tab = 'all'; // 'all' | 'local' | 'playlists'

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final allTracks = [...player.userTracks, ...sampleTracks];

    final filtered = allTracks.where((t) {
      final q = _search.toLowerCase();
      return t.title.toLowerCase().contains(q) || t.artist.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Your Library', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UploadScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildTabPills(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(player, allTracks, filtered),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white38, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (v) {
                  setState(() => _search = v);
                },
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                  border: InputBorder.none,
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                          onPressed: () {
                            setState(() => _search = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPills() {
    final tabs = [
      {'id': 'all', 'label': 'All Tracks'},
      {'id': 'local', 'label': 'Cloud Files'},
      {'id': 'playlists', 'label': 'Playlists'},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final t = tabs[i];
          final active = _tab == t['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() => _tab = t['id']!);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF1DB954) : const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    t['label']!,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(PlayerProvider player, List<Track> allTracks, List<Track> filtered) {
    if (_tab == 'playlists') return _buildEmptyState('No playlists yet', Icons.queue_music);
    if (_tab == 'local') {
      if (player.userTracks.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.white10),
              const SizedBox(height: 16),
              const Text('No cloud files yet', style: TextStyle(color: Colors.white30, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UploadScreen()),
                  );
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('UPLOAD MUSIC'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        );
      }
      return _buildTrackList(player, player.userTracks, player.userTracks);
    }
    if (filtered.isEmpty) return _buildEmptyState('No results for "$_search"', Icons.search_off);
    return _buildTrackList(player, filtered, allTracks);
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.white30, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTrackList(PlayerProvider player, List<Track> displayList, List<Track> queue) {
    return ListView.builder(
      itemCount: displayList.length,
      itemBuilder: (context, i) {
        final t = displayList[i];
        final isActive = player.currentTrack?.id == t.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => player.playTrack(t, queue),
            contentPadding: EdgeInsets.zero,
            leading: Stack(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    image: t.coverUrl != null ? DecorationImage(image: NetworkImage(t.coverUrl!), fit: BoxFit.cover) : null,
                  ),
                  child: t.coverUrl == null ? const Icon(Icons.music_note, color: Colors.white54) : null,
                ),
                if (isActive && player.isPlaying)
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                    child: const Center(child: Icon(Icons.volume_up, color: Color(0xFF1DB954), size: 20)),
                  ),
              ],
            ),
            title: Text(
              t.title,
              style: TextStyle(
                color: isActive ? const Color(0xFF1DB954) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(t.artist, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
          ),
        );
      },
    );
  }
}
