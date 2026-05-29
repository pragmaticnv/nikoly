import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio, 
      allowMultiple: true,
      withData: kIsWeb, // Important for web
    );
    if (result == null) return;

    setState(() => processing = true);

    try {
      final supabase = Supabase.instance.client;
      
      for (final file in result.files) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}-${file.name.replaceAll(' ', '_')}';
        
        // 1. Upload to storage
        if (kIsWeb) {
          await supabase.storage.from('songs').uploadBinary(fileName, file.bytes!);
        } else {
          await supabase.storage.from('songs').upload(fileName, File(file.path!));
        }

        // 2. Get public URL
        final String publicUrl = supabase.storage.from('songs').getPublicUrl(fileName);

        // 3. Save to database
        final trackData = {
          'title': file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
          'artist': 'My Upload',
          'album': 'Cloud',
          'duration': 180, // Dynamic check would be better but keeping it simple
          'artClass': 'art-${1 + (DateTime.now().millisecond % 8)}',
          'url': publicUrl,
        };

        final response = await supabase.from('songs').insert(trackData).select().single();
        final track = Track.fromMap(response);

        Provider.of<PlayerProvider>(context, listen: false).addUserTrack(track);
        setState(() {
          uploaded.insert(0, track);
        });
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F16),
      appBar: AppBar(
        title: const Text('Library & Upload', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Upload your tracks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Supported formats: MP3, WAV, FLAC', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            DottedBorder(
              color: const Color(0xFF1DB954).withOpacity(0.5),
              strokeWidth: 2,
              dashPattern: const [8, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(16),
              child: InkWell(
                onTap: processing ? null : _pickFiles,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: processing
                        ? const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF1DB954)),
                              SizedBox(height: 16),
                              Text('Uploading to Supabase...', style: TextStyle(color: Colors.white70)),
                            ],
                          )
                        : const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 64, color: Color(0xFF1DB954)),
                              SizedBox(height: 16),
                              Text('Tap to select audio files', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              Text('Files will be stored permanently', style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: ['MP3', 'WAV', 'FLAC'].map((f) => _buildFormatChip(f)).toList(),
            ),
            const SizedBox(height: 32),
            if (uploaded.isNotEmpty) ...[
              const Text('Successfully Uploaded', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: uploaded.length,
                  itemBuilder: (context, index) {
                    final track = uploaded[index];
                    return _buildUploadRow(track, player);
                  },
                ),
              ),
            ] else
              const Expanded(
                child: Center(child: Text('No uploads yet', style: TextStyle(color: Colors.white30))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadRow(Track track, PlayerProvider player) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFF1DB954).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
          ),
          title: Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: const Text('✓ Uploaded to Cloud', style: TextStyle(color: Color(0xFF1DB954), fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.play_circle_outline, color: Color(0xFF1DB954)),
            onPressed: () => player.playTrack(track),
          ),
        ),
      ),
    );
  }

  Widget _buildFormatChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white.withOpacity(0.05),
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
      side: BorderSide(color: Colors.white.withOpacity(0.1)),
    );
  }
}