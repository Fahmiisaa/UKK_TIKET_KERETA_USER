class Train {
  final int id;
  final String name;
  final String type; // e.g., 'Ekonomi', 'Bisnis', 'Eksekutif'
  final int capacity;
  final String? description;

  Train({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    this.description,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
    return Train(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      capacity: json['capacity'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'capacity': capacity,
      'description': description,
    };
  }
}
