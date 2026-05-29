import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../player/player_provider.dart';
import '../models/track.dart';
import 'upload_screen.dart';
import 'insights_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Track> _recentTracks = [];
  List<Map<String, dynamic>> _mixPlaylists = [];
  List<Map<String, dynamic>> _topArtists = [];
  List<Track> _quickPicks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _loadHomeData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch 1. Recently Played (Trending Hits)
      final trendingRes = await http.get(Uri.parse('https://saavn.sumit.co/api/search/songs?query=trending&limit=6'));
      // Fetch 2. Personalized Mixes
      final mixesRes = await http.get(Uri.parse('https://saavn.sumit.co/api/search/playlists?query=mix&limit=4'));
      // Fetch 3. Top Artists
      final artistsRes = await http.get(Uri.parse('https://saavn.sumit.co/api/search/artists?query=pop&limit=5'));
      // Fetch 4. Quick Picks (New Releases)
      final newRes = await http.get(Uri.parse('https://saavn.sumit.co/api/search/songs?query=new&limit=4'));

      List<Track> trendingTracks = [];
      List<Map<String, dynamic>> playlists = [];
      List<Map<String, dynamic>> artists = [];
      List<Track> newTracks = [];

      if (trendingRes.statusCode == 200) {
        final data = jsonDecode(trendingRes.body);
        trendingTracks = _mapSongs(data);
      }
      if (mixesRes.statusCode == 200) {
        final data = jsonDecode(mixesRes.body);
        playlists = _mapPlaylists(data);
      }
      if (artistsRes.statusCode == 200) {
        final data = jsonDecode(artistsRes.body);
        artists = _mapArtists(data);
      }
      if (newRes.statusCode == 200) {
        final data = jsonDecode(newRes.body);
        newTracks = _mapSongs(data);
      }

      if (mounted) {
        setState(() {
          _recentTracks = trendingTracks;
          _mixPlaylists = playlists;
          _topArtists = artists;
          _quickPicks = newTracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load music feed. Please try again.';
          _isLoading = false;
        });
      }
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

  List<Map<String, dynamic>> _mapPlaylists(dynamic data) {
    if (data == null || data['success'] != true || data['data'] == null) {
      return [];
    }
    final results = data['data']['results'] as List? ?? [];
    return results.map<Map<String, dynamic>>((m) {
      String? cover;
      final images = m['image'] as List?;
      if (images != null && images.isNotEmpty) {
        cover = images.last['url'] ?? images.last['link'];
      }
      final id = m['id'] ?? '';
      return {
        'id': id,
        'name': m['name'] ?? m['title'] ?? 'Playlist',
        'description': m['description'] ?? 'Curated just for you',
        'coverUrl': cover,
        'artClass': 'art-${((id.hashCode).abs() % 8) + 1}',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _mapArtists(dynamic data) {
    if (data == null || data['success'] != true || data['data'] == null) {
      return [];
    }
    final results = data['data']['results'] as List? ?? [];
    return results.map<Map<String, dynamic>>((m) {
      String? cover;
      final images = m['image'] as List?;
      if (images != null && images.isNotEmpty) {
        cover = images.last['url'] ?? images.last['link'];
      }
      final id = m['id'] ?? '';
      return {
        'name': m['name'] ?? m['title'] ?? 'Artist',
        'imageUrl': cover,
        'followers': 'Verified Artist',
        'artClass': 'art-${((id.hashCode).abs() % 8) + 1}',
      };
    }).toList();
  }

  Future<void> _handlePlaylistClick(Map<String, dynamic> playlist, PlayerProvider player) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final playlistId = playlist['id'];
      final res = await http.get(Uri.parse('https://saavn.sumit.co/api/playlists?id=$playlistId'));
      List<Track> tracks = [];

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data != null && data['success'] == true && data['data'] != null && data['data']['songs'] != null) {
          final songData = {
            'success': true,
            'data': {'results': data['data']['songs']}
          };
          tracks = _mapSongs(songData);
        }
      }

      // Defensive Fallback: If playlist details returned no songs (API bug), query its name dynamically
      if (tracks.isEmpty) {
        final name = playlist['name'] as String;
        final fallbackRes = await http.get(Uri.parse('https://saavn.sumit.co/api/search/songs?query=${Uri.encodeComponent(name)}&limit=25'));
        if (fallbackRes.statusCode == 200) {
          final data = jsonDecode(fallbackRes.body);
          tracks = _mapSongs(data);
        }
      }

      if (tracks.isNotEmpty && mounted) {
        await player.playTrack(tracks[0], tracks);
      }
    } catch (e) {
      debugPrint('Error playing playlist: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF1DB954))),
              SizedBox(height: 24),
              Text(
                'CONFIGURING YOUR FEED...',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFF3727F), size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadHomeData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'RETRY',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
                  if (_recentTracks.isNotEmpty) ...[
                    _buildSectionHeader('Trending Hits', onSeeAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InsightsScreen()),
                      );
                    }),
                    _buildHorizontalList(player, _recentTracks),
                    const SizedBox(height: 32),
                  ],
                  if (_mixPlaylists.isNotEmpty) ...[
                    _buildSectionHeader('Personalized for You'),
                    _buildMixGrid(player),
                    const SizedBox(height: 32),
                  ],
                  if (_topArtists.isNotEmpty) ...[
                    _buildSectionHeader('Your Top Artists', onSeeAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InsightsScreen()),
                      );
                    }),
                    _buildArtistList(),
                    const SizedBox(height: 32),
                  ],
                  if (_quickPicks.isNotEmpty) ...[
                    _buildSectionHeader('Quick Picks'),
                    _buildQuickPicks(player),
                    const SizedBox(height: 100),
                  ],
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
      backgroundColor: const Color(0xFF121212),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1DB954).withOpacity(0.08),
                const Color(0xFF121212),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_getGreeting(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const Text('Welcome back, Nikhil!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UploadScreen()),
                      );
                    },
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
                            child: const Center(child: Icon(Icons.volume_up, color: Color(0xFF1DB954), size: 32)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isActive ? const Color(0xFF1DB954) : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
      itemCount: _mixPlaylists.length,
      itemBuilder: (context, i) {
        final pl = _mixPlaylists[i];
        final name = pl['name'] ?? 'Playlist';
        final desc = pl['description'] ?? 'Curated for you';
        final imgUrl = pl['coverUrl'] as String?;

        return GestureDetector(
          onTap: () => _handlePlaylistClick(pl, player),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    image: imgUrl != null ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover) : null,
                  ),
                  child: imgUrl == null
                      ? Center(child: Icon(Icons.queue_music, size: 48, color: Colors.white.withOpacity(0.2)))
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtistList() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topArtists.length,
        itemBuilder: (context, i) {
          final artist = _topArtists[i];
          final name = artist['name'] ?? 'Artist';
          final imgUrl = artist['imageUrl'] as String?;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white12,
                  backgroundImage: imgUrl != null ? NetworkImage(imgUrl) : null,
                  child: imgUrl == null ? const Icon(Icons.person, color: Colors.white54, size: 40) : null,
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
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
      itemCount: _quickPicks.length,
      itemBuilder: (context, i) {
        final t = _quickPicks[i];
        final isActive = player.currentTrack?.id == t.id;
        return ListTile(
          onTap: () => player.playTrack(t, _quickPicks),
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
            child: t.coverUrl == null ? const Icon(Icons.music_note, color: Colors.white54) : null,
          ),
          title: Text(
            t.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isActive ? const Color(0xFF1DB954) : Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(t.artist, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
        );
      },
    );
  }
}