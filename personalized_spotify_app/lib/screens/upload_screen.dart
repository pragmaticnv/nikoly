import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player/player_provider.dart';
import '../models/track.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool processing = false;
  final List<Track> uploaded = [];
  int nextId = 100;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: true);
    if (result == null) return;

    setState(() => processing = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final tracks = result.files.map((file) {
      final track = Track(
        id: nextId++,
        title: file.name,
        artist: 'Local File',
        album: 'My Upload',
        duration: const Duration(minutes: 3),
        isLocal: true,
        url: file.path,
      );
      Provider.of<PlayerProvider>(context, listen: false).addUserTrack(track);
      return track;
    }).toList();

    setState(() {
      uploaded.insertAll(0, tracks);
      processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Music')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: _pickFiles,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: processing
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.cloud_upload, size: 48, color: Colors.white54),
                            SizedBox(height: 8),
                            Text('Tap to select audio files', style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (uploaded.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Uploaded (${uploaded.length})', style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: uploaded.length,
                  itemBuilder: (context, index) {
                    final track = uploaded[index];
                    return ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.audio_file, color: Colors.white54),
                      ),
                      title: Text(track.title),
                      subtitle: const Text('Uploaded successfully', style: TextStyle(color: Colors.greenAccent)),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_circle, color: Colors.white),
                        onPressed: () => player.playTrack(track),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}