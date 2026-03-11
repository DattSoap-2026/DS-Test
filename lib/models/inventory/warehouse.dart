class Warehouse {
  final String id;
  final String name;
  final String? location;
  final bool isActive;

  Warehouse({
    required this.id,
    required this.name,
    this.location,
    this.isActive = true,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'location': location, 'isActive': isActive};
  }
}
