import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player/player_provider.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onOpenNowPlaying;

  const MiniPlayer({super.key, required this.onOpenNowPlaying});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final track = player.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final elapsed = Duration(
      milliseconds: (player.progress * (track.duration.inMilliseconds)).round(),
    );

    String format(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onOpenNowPlaying,
      child: Container(
        color: const Color(0xFF161626),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.music_note, color: Colors.white54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(track.artist, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            Text(format(elapsed), style: const TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(width: 10),
            IconButton(
              onPressed: player.togglePlay,
              icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }
}