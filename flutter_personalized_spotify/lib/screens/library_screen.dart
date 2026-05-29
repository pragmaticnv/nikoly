import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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
  List<Track> _discoverTracks = [];
  bool _isLoadingDiscover = false;
  String _discoverError = '';
  Timer? _debounce;

  Future<void> _fetchJioSaavnTracks([String query = '']) async {
    if (!mounted) return;
    setState(() {
      _isLoadingDiscover = true;
      _discoverError = '';
    });
    try {
      final q = query.trim().isEmpty ? 'trending' : query.trim();
      final urlStr = 'https://saavn.sumit.co/api/search/songs?query=${Uri.encodeComponent(q)}&limit=30';

      final response = await http.get(Uri.parse(urlStr));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['success'] == true && data['data'] != null) {
          final results = data['data']['results'] as List? ?? [];
          final mapped = results.map((m) {
            // Extract cover image
            String? cover;
            final images = m['image'] as List?;
            if (images != null && images.isNotEmpty) {
              cover = images.last['url'] ?? images.last['link'];
            }

            // Extract download stream URL
            String? audioUrl;
            final downloads = m['downloadUrl'] as List?;
            if (downloads != null && downloads.isNotEmpty) {
              audioUrl = downloads.last['url'] ?? downloads.last['link'];
            }

            // Extract artist list
            String artist = 'Unknown Artist';
            final artistsObj = m['artists'];
            if (artistsObj != null && artistsObj['primary'] != null) {
              final primaryArtists = artistsObj['primary'] as List;
              if (primaryArtists.isNotEmpty) {
                artist = primaryArtists.map((a) => a['name'] ?? '').where((name) => (name as String).isNotEmpty).join(', ');
              }
            }

            final durationSec = m['duration'];
            int durationInt = 180;
            if (durationSec is int) {
              durationInt = durationSec;
            } else if (durationSec is String) {
              durationInt = int.tryParse(durationSec) ?? 180;
            }

            final songId = m['id'] ?? UniqueKey().toString();

            return Track(
              id: 'saavn-$songId',
              title: m['name'] ?? m['title'] ?? 'Unknown',
              artist: artist,
              album: (m['album'] != null ? m['album']['name'] : null) ?? 'Single',
              duration: Duration(seconds: durationInt),
              coverUrl: cover,
              url: audioUrl,
              artClass: 'art-${((songId.hashCode).abs() % 8) + 1}',
              isLocal: false,
            );
          }).toList();

          if (mounted) {
            setState(() {
              _discoverTracks = mapped;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _discoverError = 'Server error: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _discoverError = 'Connection failed. Please check internet connection.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDiscover = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final allTracks = [...player.userTracks, ...sampleTracks];

    final filtered = allTracks.where((t) {
      final q = _search.toLowerCase();
      return t.title.toLowerCase().contains(q) || t.artist.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Your Library', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {}),
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
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white38, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (v) {
                  setState(() => _search = v);
                  if (_tab == 'discover') {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _fetchJioSaavnTracks(v);
                    });
                  }
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
                            if (_tab == 'discover') {
                              _fetchJioSaavnTracks('');
                            }
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
      {'id': 'discover', 'label': 'Discover Online'},
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
                if (t['id'] == 'discover' && _discoverTracks.isEmpty) {
                  _fetchJioSaavnTracks(_search);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF1DB954) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: Text(t['label']!, style: TextStyle(color: active ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12))),
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
      if (player.userTracks.isEmpty) return _buildEmptyState('No cloud files yet', Icons.cloud_off);
      return _buildTrackList(player, player.userTracks, player.userTracks);
    }
    if (_tab == 'discover') {
      if (_isLoadingDiscover) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF1DB954))),
              SizedBox(height: 16),
              Text('Searching JioSaavn...', style: TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        );
      }
      if (_discoverError.isNotEmpty) {
        return _buildEmptyState(_discoverError, Icons.error_outline);
      }
      if (_discoverTracks.isEmpty) {
        return _buildEmptyState('No online results', Icons.search_off);
      }
      return _buildTrackList(player, _discoverTracks, _discoverTracks);
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
            title: Text(t.title, style: TextStyle(color: isActive ? const Color(0xFF1DB954) : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(t.artist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
          ),
        );
      },
    );
  }
}
