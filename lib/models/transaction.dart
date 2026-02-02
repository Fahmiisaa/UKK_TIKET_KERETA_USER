class Transaction {
  final String id;
  final double amount;
  final String status; // 'paid', 'pending', 'cancelled'
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  // Untuk keperluan konversi data dari API nantinya
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
