class User {
  final int? id;
  final String name;
  final String username;
  final String nik;
  final String phone;
  final String address;
  final String? password;
  final String role; // 'customer' or 'admin'
  final String? token;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.nik,
    required this.phone,
    required this.address,
    this.password,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      nik: json['nik'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? 'customer',
      token: json['token'],
    );
  }

  get email => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'nik': nik,
      'phone': phone,
      'address': address,
      'password': password,
      'role': role,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? username,
    String? nik,
    String? phone,
    String? address,
    String? password,
    String? role,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      nik: nik ?? this.nik,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
