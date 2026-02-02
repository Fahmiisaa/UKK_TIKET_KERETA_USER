import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/train.dart';
import '../models/schedule.dart';
import '../models/booking.dart';
import '../models/transaction.dart';

class ApiService {
  static const String baseUrl = 'https://micke.my.id/api/ukk/';

  // Get stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Set token
  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Clear token
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Helper method untuk handle error response
  String _handleErrorResponse(int statusCode, String responseBody) {
    print('API Error Response: Status $statusCode, Body: $responseBody');

    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid. Periksa data yang dimasukkan.';
      case 401:
        return 'Akses ditolak. Silakan login kembali.';
      case 403:
        return 'Anda tidak memiliki izin untuk melakukan tindakan ini.';
      case 404:
        return 'Data atau endpoint tidak ditemukan. Periksa koneksi atau hubungi administrator.';
      case 422:
        return 'Data yang dimasukkan tidak valid. Periksa kembali form.';
      case 500:
        return 'Terjadi kesalahan pada server. Coba lagi nanti.';
      default:
        // Coba parse error message dari response
        try {
          final errorData = json.decode(responseBody);
          if (errorData['message'] != null) {
            return errorData['message'];
          }
          if (errorData['error'] != null) {
            return errorData['error'];
          }
        } catch (e) {
          print('Failed to parse error response: $e');
        }
        return 'Terjadi kesalahan tidak dikenal. Status: $statusCode';
    }
  }

  // Generic GET request
  Future<Map<String, dynamic>> _get(String endpoint) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('API Request [GET]: $baseUrl$endpoint');
    print('Headers: $headers');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      print('API Response [GET $endpoint]: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          _handleErrorResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      print('Network Error [GET $endpoint]: $e');
      throw Exception(
        'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      );
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = data.entries
        .map(
          (entry) =>
              '${entry.key}=${Uri.encodeComponent(entry.value.toString())}',
        )
        .join('&');

    print('API Request [POST]: $baseUrl$endpoint');
    print('Headers: $headers');
    print('Request Body: $body');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body,
      );

      print('API Response [POST $endpoint]: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          _handleErrorResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      print('Network Error [POST $endpoint]: $e');
      throw Exception(
        'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      );
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> _put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('API Request [PUT]: $baseUrl$endpoint');
    print('Headers: $headers');
    print('Request Body: ${json.encode(data)}');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      print('API Response [PUT $endpoint]: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          _handleErrorResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      print('Network Error [PUT $endpoint]: $e');
      throw Exception(
        'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      );
    }
  }

  // Generic DELETE request
  Future<void> _delete(String endpoint) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('API Request [DELETE]: $baseUrl$endpoint');
    print('Headers: $headers');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      print('API Response [DELETE $endpoint]: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          _handleErrorResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      print('Network Error [DELETE $endpoint]: $e');
      throw Exception(
        'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      );
    }
  }

  // Authentication
  Future<User> register(
    String name,
    String username,
    String nik,
    String phone,
    String address,
    String password,
  ) async {
    try {
      final data = await _post('/register.php', {
        'name': name,
        'username': username,
        'nik': nik,
        'phone': phone,
        'address': address,
        'password': password,
      });

      if (data['status'] == 'error') {
        throw Exception(data['message'] ?? 'Registration failed');
      }

      final user = User.fromJson(data['user'] ?? data);
      if (data['token'] != null) {
        await _setToken(data['token']);
      }
      return user;
    } catch (e) {
      print('Registration Error: $e');
      rethrow;
    }
  }

  Future<User> login(String username, String password) async {
    try {
      final data = await _post('/login.php', {
        'username': username,
        'password': password,
      });

      if (data['status'] == 'error') {
        throw Exception(data['message'] ?? 'Login failed');
      }

      final userData = data['data'];
      final profile = userData['profile'];

      final user = User(
        id: int.tryParse(userData['user_id'] ?? ''),
        name: profile['nama_penumpang'] ?? '',
        username:
            username, // Use the input username since API doesn't return it
        nik: profile['nik'] ?? '',
        phone: profile['telp'] ?? '',
        address: profile['alamat'] ?? '',
        role:
            userData['role'] == 'penumpang'
                ? 'customer'
                : userData['role'] ?? 'customer',
        token: data['token'], // API doesn't return token, so this will be null
      );

      // Since API doesn't return token, we might need to handle authentication differently
      // For now, we'll assume login is successful without token
      return user;
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  // Trains
  Future<List<Train>> getTrains() async {
    try {
      final data = await _get('/kereta.php');
      final trains =
          (data['data'] ?? data) is List
              ? (data['data'] ?? data)
                  .map((json) => Train.fromJson(json))
                  .toList()
              : [];
      return trains;
    } catch (e) {
      print('Get Trains Error: $e');
      rethrow;
    }
  }

  Future<Train> createTrain(Train train) async {
    try {
      final data = await _post('/kereta.php', train.toJson());
      return Train.fromJson(data['data'] ?? data);
    } catch (e) {
      print('Create Train Error: $e');
      rethrow;
    }
  }

  Future<Train> updateTrain(int id, Train train) async {
    try {
      final data = await _put('/kereta.php/$id', train.toJson());
      return Train.fromJson(data['data'] ?? data);
    } catch (e) {
      print('Update Train Error: $e');
      rethrow;
    }
  }

  Future<void> deleteTrain(int id) async {
    try {
      await _delete('/kereta.php/$id');
    } catch (e) {
      print('Delete Train Error: $e');
      rethrow;
    }
  }

  // Schedules
  Future<List<Schedule>> getSchedules() async {
    try {
      final data = await _get('/jadwal-kereta.php');
      final schedules =
          (data['data'] ?? data) is List
              ? (data['data'] ?? data)
                  .map((json) => Schedule.fromJson(json))
                  .toList()
              : [];
      return schedules;
    } catch (e) {
      print('Get Schedules Error: $e');
      rethrow;
    }
  }

  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final data = await _post('/jadwal-kereta.php', schedule.toJson());
      return Schedule.fromJson(data['data'] ?? data);
    } catch (e) {
      print('Create Schedule Error: $e');
      rethrow;
    }
  }

  Future<Schedule> updateSchedule(int id, Schedule schedule) async {
    try {
      final data = await _put('/jadwal-kereta.php/$id', schedule.toJson());
      return Schedule.fromJson(data['data'] ?? data);
    } catch (e) {
      print('Update Schedule Error: $e');
      rethrow;
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      await _delete('/jadwal-kereta.php/$id');
    } catch (e) {
      print('Delete Schedule Error: $e');
      rethrow;
    }
  }

  // Bookings
  Future<List<Booking>> getBookings() async {
    try {
      final data = await _get('/booking.php');
      final bookings =
          (data['data'] ?? data) is List
              ? (data['data'] ?? data)
                  .map((json) => Booking.fromJson(json))
                  .toList()
              : [];
      return bookings;
    } catch (e) {
      print('Get Bookings Error: $e');
      rethrow;
    }
  }

  Future<Booking> createBooking(Booking booking) async {
    try {
      final data = await _post('/booking.php', booking.toJson());
      return Booking.fromJson(data['data'] ?? data);
    } catch (e) {
      print('Create Booking Error: $e');
      rethrow;
    }
  }

  Future<void> deleteBooking(int id) async {
    try {
      await _delete('/booking.php/$id');
    } catch (e) {
      print('Delete Booking Error: $e');
      rethrow;
    }
  }

  // Transactions
  Future<List<Transaction>> getTransactionHistory() async {
    try {
      final data = await _get('/transaksi/history.php');
      final transactions =
          (data['data'] ?? data) is List
              ? (data['data'] ?? data)
                  .map((json) => Transaction.fromJson(json))
                  .toList()
              : [];
      return transactions;
    } catch (e) {
      print('Get Transaction History Error: $e');
      rethrow;
    }
  }

  // Customers (for admin)
  Future<List<User>> getCustomers() async {
    try {
      final data = await _get('/pelanggan.php');
      final customers =
          (data['data'] ?? data) is List
              ? (data['data'] ?? data)
                  .map((json) => User.fromJson(json))
                  .toList()
              : [];
      return customers;
    } catch (e) {
      print('Get Customers Error: $e');
      rethrow;
    }
  }

  Future<User> updateCustomer(int id, User user) async {
    try {
      final data = await _put('/pelanggan.php/$id', user.toJson());
      return User.fromJson(data['data'] ?? data);
    } catch (e) {
      print('Update Customer Error: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _delete('/pelanggan.php/$id');
    } catch (e) {
      print('Delete Customer Error: $e');
      rethrow;
    }
  }

  // Reports
  Future<Map<String, dynamic>> getMonthlyReport(DateTime date) async {
    try {
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final data = await _get('/laporan/bulanan.php?month=$month&year=$year');
      return data;
    } catch (e) {
      print('Get Monthly Report Error: $e');
      rethrow;
    }
  }

  // Print ticket
  Future<String> printTicket(int transactionId) async {
    try {
      final data = await _get('/transaksi/$transactionId/print.php');
      return data['pdf_url'] ?? '';
    } catch (e) {
      print('Print Ticket Error: $e');
      rethrow;
    }
  }
}
