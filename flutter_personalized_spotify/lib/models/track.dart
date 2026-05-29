class Track {
  final dynamic id;
  final String title;
  final String artist;
  final String album;
  final Duration? duration;
  final String? coverUrl;
  final String? url;
  final String? artClass;
  final bool isLocal;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.duration,
    this.coverUrl,
    this.url,
    this.artClass,
    this.isLocal = false,
  });

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'],
      title: map['title'] ?? 'Unknown',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Cloud',
      duration: map['duration'] != null ? Duration(seconds: map.containsKey('duration') ? (map['duration'] is int ? map['duration'] : (map['duration'] as double).toInt()) : 0) : null,
      coverUrl: map['coverUrl'],
      url: map['url'],
      artClass: map['artClass'],
      isLocal: false,
    );
  }
}