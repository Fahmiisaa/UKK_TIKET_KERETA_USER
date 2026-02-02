class Schedule {
  final String id;
  final String departureStation;
  final String arrivalStation;
  final double price;
  final String trainName;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String date; // Tambahan untuk membedakan hari

  Schedule({
    required this.id,
    required this.departureStation,
    required this.arrivalStation,
    required this.price,
    this.trainName = "Executive Train",
    this.departureTime = "00:00",
    this.arrivalTime = "00:00",
    this.duration = "0h",
    this.date = "",
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id']?.toString() ?? '',
      departureStation: json['departureStation'] ?? 'Unknown',
      arrivalStation: json['arrivalStation'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      trainName: json['trainName'] ?? 'Executive Train',
      departureTime: json['departureTime'] ?? '--:--',
      arrivalTime: json['arrivalTime'] ?? '--:--',
      duration: json['duration'] ?? '-',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
      'price': price,
      'trainName': trainName,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'date': date,
    };
  }
}
