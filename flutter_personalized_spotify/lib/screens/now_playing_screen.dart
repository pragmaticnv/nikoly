import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player/player_provider.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final track = player.currentTrack;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Now Playing')),
        body: const Center(child: Text('Nothing playing yet')),
      );
    }

    String format(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white12,
              ),
              child: const Center(child: Icon(Icons.music_note, size: 120, color: Colors.white30)),
            ),
            const SizedBox(height: 20),
            Text(track.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(track.artist, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            Slider(
              value: player.progress.clamp(0.0, 1.0),
              onChanged: (v) => player.seek(v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(format(Duration(milliseconds: (player.progress * (track.duration?.inMilliseconds ?? 0)).round()))),
                Text(format(track.duration ?? Duration.zero)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.shuffle), color: player.isShuffle ? Colors.greenAccent : Colors.white, onPressed: player.toggleShuffle),
                IconButton(icon: const Icon(Icons.skip_previous), onPressed: player.prev),
                FloatingActionButton(
                  onPressed: player.togglePlay,
                  child: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(icon: const Icon(Icons.skip_next), onPressed: player.next),
                IconButton(
                  icon: Icon(player.repeatMode == 'one' ? Icons.repeat_one : Icons.repeat),
                  color: player.repeatMode != 'none' ? Colors.greenAccent : Colors.white,
                  onPressed: player.toggleRepeat,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}