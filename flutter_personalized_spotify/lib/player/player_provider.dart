import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/track.dart';

final sampleTracks = [
  Track(
    id: 1,
    title: 'Blinding Lights',
    artist: 'The Weeknd',
    album: 'After Hours',
    duration: const Duration(minutes: 3, seconds: 20),
    coverUrl:
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&q=80',
  ),
  Track(
    id: 2,
    title: 'Levitating',
    artist: 'Dua Lipa',
    album: 'Future Nostalgia',
    duration: const Duration(minutes: 3, seconds: 23),
    coverUrl:
        'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=300&q=80',
  ),
  Track(
    id: 3,
    title: 'Peaches',
    artist: 'Justin Bieber',
    album: 'Justice',
    duration: const Duration(minutes: 3, seconds: 18),
    coverUrl:
        'https://images.unsplash.com/photo-1511735111819-9a3f7709049c?w=300&q=80',
  ),
];

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audio = AudioPlayer();
  List<Track> queue = [...sampleTracks];
  int queueIndex = 0;
  bool isShuffle = false;
  String repeatMode = 'none'; // none | one | all
  bool isLiked = false;
  double progress = 0.0;
  List<Track> userTracks = [];

  Track? get currentTrack => queue.isEmpty ? null : queue[queueIndex];
  bool get isPlaying => _audio.playing;

  PlayerProvider() {
    _audio.positionStream.listen((position) {
      if (_audio.duration != null && _audio.duration!.inMilliseconds > 0) {
        progress = position.inMilliseconds / _audio.duration!.inMilliseconds;
        notifyListeners();
      }
    });

    _audio.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleTrackEnd();
      }
      notifyListeners();
    });

    _fetchTracks();
  }

  Future<void> _fetchTracks() async {
    try {
      final data = await Supabase.instance.client
          .from('songs')
          .select()
          .order('created_at', ascending: false);
      
      userTracks = (data as List).map((m) => Track.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching tracks: $e');
    }
  }

  Future<void> playTrack(Track track, [List<Track>? playlist]) async {
    if (playlist != null) queue = playlist;
    queueIndex = queue.indexWhere((t) => t.id == track.id).clamp(0, queue.length - 1);
    final url = track.url;
    if (url != null) {
      await _audio.setUrl(url);
    } else {
      await _audio.setUrl(''); // placeholder
    }
    await _audio.play();
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (_audio.playing) {
      await _audio.pause();
    } else {
      await _audio.play();
    }
    notifyListeners();
  }

  Future<void> seek(double value) async {
    if (_audio.duration != null) {
      final position = _audio.duration! * value;
      await _audio.seek(position);
    }
  }

  void toggleShuffle() {
    isShuffle = !isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    repeatMode = repeatMode == 'none'
        ? 'all'
        : repeatMode == 'all'
            ? 'one'
            : 'none';
    notifyListeners();
  }

  void toggleLike() {
    isLiked = !isLiked;
    notifyListeners();
  }

  void addUserTrack(Track track) {
    userTracks = [track, ...userTracks];
    notifyListeners();
  }

  void next() {
    if (queue.isEmpty) return;
    if (isShuffle) {
      queueIndex = Random().nextInt(queue.length);
    } else {
      queueIndex = (queueIndex + 1) % queue.length;
    }
    playTrack(queue[queueIndex], queue);
  }

  void prev() {
    if (queue.isEmpty) return;
    queueIndex = (queueIndex - 1 + queue.length) % queue.length;
    playTrack(queue[queueIndex], queue);
  }

  void _handleTrackEnd() {
    if (repeatMode == 'one') {
      _audio.seek(Duration.zero);
      _audio.play();
      return;
    }
    if (repeatMode == 'all' || queue.length > 1) {
      next();
      return;
    }
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }
}