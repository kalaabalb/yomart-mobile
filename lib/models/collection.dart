class StoreCollection {
  const StoreCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.productIds,
    required this.sortOrder,
    required this.isActive,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<String> productIds;
  final int sortOrder;
  final bool isActive;

  factory StoreCollection.fromJson(Map<String, dynamic> json) {
    return StoreCollection(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      productIds: (json['productIds'] as List? ?? const [])
          .map((value) => value.toString())
          .toList(),
      sortOrder: int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
      isActive: json['isActive'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'subtitle': subtitle,
        'productIds': productIds,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };
}
