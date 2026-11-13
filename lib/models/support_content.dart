class SupportContent {
  const SupportContent(
      {required this.title, required this.body, required this.sortOrder});
  final String title;
  final String body;
  final int sortOrder;

  factory SupportContent.fromJson(Map<String, dynamic> json) => SupportContent(
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );
}
