class Booking {
  final int? id;
  final int userId;
  final int scheduleId;
  final int passengerCount;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;
  final List<Passenger>? passengers;

  Booking({
    this.id,
    required this.userId,
    required this.scheduleId,
    required this.passengerCount,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.passengers,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      scheduleId: json['schedule_id'],
      passengerCount: json['passenger_count'],
      totalPrice: json['total_price'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      passengers:
          json['passengers'] != null
              ? (json['passengers'] as List)
                  .map((p) => Passenger.fromJson(p))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'schedule_id': scheduleId,
      'passenger_count': passengerCount,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'passengers': passengers?.map((p) => p.toJson()).toList(),
    };
  }
}

class Passenger {
  final String name;
  final String idNumber;
  final String seatNumber;

  Passenger({
    required this.name,
    required this.idNumber,
    required this.seatNumber,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      name: json['name'],
      idNumber: json['id_number'],
      seatNumber: json['seat_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'id_number': idNumber, 'seat_number': seatNumber};
  }
}
