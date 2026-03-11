class Holiday {
  final String id;
  final String name;
  final DateTime date;
  final bool isRecurring; // Annual holiday (not strictly used if we store per year)
  final String? description;

  Holiday({
    required this.id,
    required this.name,
    required this.date,
    this.isRecurring = false,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'description': description,
    };
  }

  factory Holiday.fromMap(Map<String, dynamic> map) {
    return Holiday(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      date: DateTime.parse(map['date']),
      isRecurring: map['isRecurring'] ?? false,
      description: map['description'],
    );
  }
}
