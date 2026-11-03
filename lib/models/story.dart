class Story {
  const Story({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.format,
    required this.durationSeconds,
    required this.playbackUrl,
    required this.playbackExpiresAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String format;
  final double durationSeconds;
  final String playbackUrl;
  final DateTime? playbackExpiresAt;

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        format: json['format']?.toString() ?? '',
        durationSeconds: (json['durationSeconds'] as num?)?.toDouble() ?? 0,
        playbackUrl: json['playbackUrl']?.toString() ?? '',
        playbackExpiresAt:
            DateTime.tryParse(json['playbackExpiresAt']?.toString() ?? ''),
      );
}

bool isSafeStoryPlaybackUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      (uri.port != 443 && uri.hasPort) ||
      uri.hasFragment ||
      uri.query.isEmpty ||
      !(uri.host == 'api.cloudinary.com' ||
          uri.host.endsWith('.cloudinary.com'))) {
    return false;
  }
  final segments = uri.pathSegments;
  return segments.length >= 4 &&
      segments[0] == 'v1_1' &&
      segments[2] == 'video' &&
      segments[3] == 'download';
}
