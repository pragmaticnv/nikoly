class Track {
  final int id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? coverUrl;
  final bool isLocal;
  final String? url;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.coverUrl,
    this.isLocal = false,
    this.url,
  });
}