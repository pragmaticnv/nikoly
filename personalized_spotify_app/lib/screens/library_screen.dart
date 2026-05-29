import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player/player_provider.dart';
import '../models/track.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _search = '';
  String _tab = 'all';

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final allTracks = [...player.userTracks, ...sampleTracks];

    final filtered = allTracks.where((t) {
      final q = _search.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.artist.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Placeholder()),
            ), // placeholder for Upload
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.search, color: Colors.white54),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search songs, artists...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_search.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _search = ''),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tabButton('all', 'All Tracks'),
                _tabButton('local', 'Local Files'),
                _tabButton('playlists', 'Playlists'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _tab == 'playlists'
                  ? _buildPlaylists()
                  : _tab == 'local'
                      ? _buildLocal(player, allTracks, filtered)
                      : _buildAllTracks(filtered, allTracks, player),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String id, String label) {
    final active = _tab == id;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            active ? const Color(0xFF1DB954) : const Color(0xFF1A1A2E),
      ),
      onPressed: () => setState(() => _tab = id),
      child: Text(label),
    );
  }

  Widget _buildPlaylists() {
    return const Center(child: Text('Playlists screen (placeholder)'));
  }

  Widget _buildLocal(
    PlayerProvider player,
    List<Track> allTracks,
    List<Track> filtered,
  ) {
    final list = [...sampleTracks.take(2), ...player.userTracks];
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.audio_file, size: 72, color: Colors.white24),
            const SizedBox(height: 12),
            const Text('No local files yet'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const Placeholder())),
              child: const Text('Upload Music'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: list.map((t) => _trackTile(player, t, allTracks)).toList(),
    );
  }

  Widget _buildAllTracks(
    List<Track> filtered,
    List<Track> allTracks,
    PlayerProvider player,
  ) {
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No results for "$_search"',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView(
      children: filtered.map((t) => _trackTile(player, t, allTracks)).toList(),
    );
  }

  Widget _trackTile(PlayerProvider player, Track track, List<Track> allTracks) {
    final isActive = player.currentTrack?.id == track.id;
    return ListTile(
      onTap: () => player.playTrack(track, allTracks),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.music_note, color: Colors.white54),
      ),
      title: Text(
        track.title,
        style: TextStyle(color: isActive ? Colors.greenAccent : null),
      ),
      subtitle: Text(track.artist),
      trailing: isActive && player.isPlaying
          ? const Icon(Icons.equalizer, color: Colors.greenAccent)
          : null,
    );
  }
}
