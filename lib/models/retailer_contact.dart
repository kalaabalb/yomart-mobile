class RetailerContact {
  const RetailerContact({
    required this.label,
    required this.description,
    required this.type,
    required this.value,
    required this.placement,
    required this.displayOrder,
  });

  final String label;
  final String description;
  final String type;
  final String value;
  final String placement;
  final int displayOrder;

  factory RetailerContact.fromJson(Map<String, dynamic> json) =>
      RetailerContact(
        label: json['label']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        placement: json['placement']?.toString() ?? '',
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      );

  bool appearsAt(String target) => placement == 'all' || placement == target;
}
