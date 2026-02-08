class Booking {
  final String? id;
  final String userId;
  final String trainId;
  final int passengerCount;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime date;
  final List<String> passengers;

  Booking({
    this.id,
    required this.userId,
    required this.trainId,
    required this.passengerCount,
    required this.totalPrice,
    required this.status,
    required this.date,
    required this.passengers,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      trainId: json['train_id']?.toString() ?? '',
      passengerCount: json['passenger_count'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      passengers: List<String>.from(json['passengers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'train_id': trainId,
      'passenger_count': passengerCount,
      'total_price': totalPrice,
      'status': status,
      'date': date.toIso8601String(),
      'passengers': passengers,
    };
  }
}
