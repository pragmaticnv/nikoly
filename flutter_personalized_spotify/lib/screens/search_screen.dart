import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../player/player_provider.dart';
import '../models/track.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Track> _searchResults = [];
  List<Track> _trendingTracks = [];
  bool _isLoading = false;
  bool _isLoadingTrending = false;
  String _error = '';
  Timer? _debounce;

  final List<Map<String, dynamic>> _browseCategories = [
    { 'name': 'Pop Hits', 'colors': [0xFFE02C5F, 0xFFF27E9B], 'icon': Icons.music_note },
    { 'name': 'Hip-Hop', 'colors': [0xFF4776E6, 0xFF8E54E9], 'icon': Icons.album },
    { 'name': 'Bollywood', 'colors': [0xFFF857A6, 0xFFFF5858], 'icon': Icons.radio },
    { 'name': 'Chill Vibes', 'colors': [0xFF11998E, 0xFF38EF7D], 'icon': Icons.spa },
    { 'name': 'Rock Classics', 'colors': [0xFFFF9966, 0xFFFF5E62], 'icon': Icons.legend_toggle },
    { 'name': 'New Releases', 'colors': [0xFF2193B0, 0xFF6DD5ED], 'icon': Icons.new_releases },
  ];

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    if (!mounted) return;
    setState(() => _isLoadingTrending = true);
    try {
      final res = await http.get(Uri.parse('https://saavn.sumit.co/api/search/songs?query=trending&limit=8'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final tracks = _mapSongs(data);
        if (mounted) {
          setState(() {
            _trendingTracks = tracks;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading trending search tracks: $e');
    } finally {
      if (mounted) setState(() => _isLoadingTrending = false);
    }
  }

  Future<void> _fetchSearchResults(String query) async {
    if (!mounted) return;
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _error = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final res = await http.get(Uri.parse('https://saavn.sumit.co/api/search/songs?query=${Uri.encodeComponent(query.trim())}&limit=30'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final tracks = _mapSongs(data);
        if (mounted) {
          setState(() {
            _searchResults = tracks;
          });
        }
      } else {
        if (mounted) setState(() => _error = 'Server error: ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Connection failed. Please check internet.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Track> _mapSongs(dynamic data) {
    if (data == null || data['success'] != true || data['data'] == null) {
      return [];
    }
    final results = data['data']['results'] as List? ?? [];
    return results.map<Track>((m) {
      String? cover;
      final images = m['image'] as List?;
      if (images != null && images.isNotEmpty) {
        cover = images.last['url'] ?? images.last['link'];
      }

      String? audioUrl;
      final downloads = m['downloadUrl'] as List?;
      if (downloads != null && downloads.isNotEmpty) {
        audioUrl = downloads.last['url'] ?? downloads.last['link'];
      }

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
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSearchResults(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildSearchField(),
          ),
          if (_searchController.text.trim().isNotEmpty) ...[
            _buildSearchResultsContent(player),
          ] else ...[
            _buildBrowseLandingContent(player),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(500),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  setState(() {});
                  _onSearchChanged(v);
                },
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'What do you want to listen to?',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchResults = [];
                    _error = '';
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsContent(PlayerProvider player) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF1DB954))),
              SizedBox(height: 16),
              Text(
                'SEARCHING JIOSAAVN...',
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFF3727F), size: 48),
              const SizedBox(height: 16),
              Text(_error, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.white10),
              SizedBox(height: 16),
              Text('No online results', style: TextStyle(color: Colors.white30, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final t = _searchResults[i];
            final isActive = player.currentTrack?.id == t.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => player.playTrack(t, _searchResults),
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
                  style: TextStyle(color: isActive ? const Color(0xFF1DB954) : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(t.artist, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
              ),
            );
          },
          childCount: _searchResults.length,
        ),
      ),
    );
  }

  Widget _buildBrowseLandingContent(PlayerProvider player) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: 8),
          const Text('Browse All', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
            itemCount: _browseCategories.length,
            itemBuilder: (context, i) {
              final cat = _browseCategories[i];
              final name = cat['name'] as String;
              final colors = cat['colors'] as List<int>;
              final icon = cat['icon'] as IconData;

              return InkWell(
                onTap: () {
                  setState(() {
                    _searchController.text = name;
                  });
                  _fetchSearchResults(name);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors.map((c) => Color(c)).toList(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Positioned(
                        bottom: -16,
                        right: -16,
                        child: Transform.rotate(
                          angle: 0.4,
                          child: Icon(icon, size: 64, color: Colors.white.withOpacity(0.15)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          if (_trendingTracks.isNotEmpty) ...[
            const Text('Trending Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_isLoadingTrending)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF1DB954))),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trendingTracks.length,
                itemBuilder: (context, i) {
                  final t = _trendingTracks[i];
                  final isActive = player.currentTrack?.id == t.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () => player.playTrack(t, _trendingTracks),
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
                        style: TextStyle(color: isActive ? const Color(0xFF1DB954) : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(t.artist, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
                    ),
                  );
                },
              ),
            const SizedBox(height: 100),
          ],
        ]),
      ),
    );
  }
}
