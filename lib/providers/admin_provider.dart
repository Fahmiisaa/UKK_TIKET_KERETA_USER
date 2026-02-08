import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;

  // --- DATA LISTS ---
  List<dynamic> _listKereta = [];
  List<dynamic> _listJadwal = [];
  List<dynamic> _listGerbong = [];
  List<dynamic> _listTransaksi = [];

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  List<dynamic> get listKereta => _listKereta;
  List<dynamic> get listJadwal => _listJadwal;
  List<dynamic> get listGerbong => _listGerbong;
  List<dynamic> get listTransaksi => _listTransaksi;

  // --- BASE URL ---
  String get baseUrl => 'https://micke.my.id/api/ukk';

  // ========================================================
  // 1. MANAJEMEN KERETA (ARMADA)
  // ========================================================

  Future<void> getKereta() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/kereta.php'));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listKereta = data['data'];
      } else {
        _listKereta = [];
      }
    } catch (e) {
      debugPrint("Error Get Kereta: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addKereta(
    String nama,
    String deskripsi,
    String kelas,
    String jumlahGerbong,
    String kuota,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kereta.php'),
        body: {
          'nama_kereta': nama,
          'deskripsi': deskripsi,
          'kelas': kelas,
          'jumlah_gerbong': jumlahGerbong,
          'kuota': kuota,
        },
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getKereta(); // Refresh list setelah tambah
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Add Kereta: $e");
      return false;
    }
  }

  Future<bool> updateKereta(
    String id,
    String nama,
    String deskripsi,
    String kelas,
    String jumlahGerbong,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/kereta.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama_kereta': nama,
          'deskripsi': deskripsi,
          'kelas': kelas,
          'jumlah_gerbong': jumlahGerbong,
        }),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getKereta(); // Refresh list setelah update
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Update Kereta: $e");
      return false;
    }
  }

  Future<String> deleteKereta(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/kereta.php?id=$id'),
      );
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listKereta.removeWhere((item) => item['id'].toString() == id);
        notifyListeners();
        return "success";
      } else {
        return data['message'] ?? "Gagal menghapus data";
      }
    } catch (e) {
      return "Terjadi kesalahan koneksi";
    }
  }

  // ========================================================
  // 2. MANAJEMEN GERBONG (COACH)
  // ========================================================

  Future<void> getGerbong(String idKereta) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Endpoint: gerbong.php?id_kereta=...
      final response = await http.get(
        Uri.parse('$baseUrl/gerbong.php?id_kereta=$idKereta'),
      );
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listGerbong = data['data'];
      } else {
        _listGerbong = [];
      }
    } catch (e) {
      debugPrint("Error Get Gerbong: $e");
      _listGerbong = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // ========================================================
  // 3. MANAJEMEN JADWAL (SCHEDULE)
  // ========================================================

  Future<void> getJadwal() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/jadwal.php'));
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _listJadwal = data['data'];
      }
    } catch (e) {
      debugPrint("Error Get Jadwal: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addJadwal(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jadwal.php'),
        body: body,
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getJadwal();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Add Jadwal: $e");
      return false;
    }
  }

  Future<bool> updateJadwal(String id, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/jadwal.php?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        await getJadwal();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Update Jadwal: $e");
      return false;
    }
  }

  Future<String> deleteJadwal(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/jadwal.php?id=$id'),
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        _listJadwal.removeWhere((item) => item['id'].toString() == id);
        notifyListeners();
        return "success";
      }
      return data['message'] ?? "Gagal menghapus jadwal";
    } catch (e) {
      return "Error Koneksi";
    }
  }

  // ========================================================
  // 4. MANAJEMEN TRANSAKSI (HISTORY & CHECKOUT)
  // ========================================================

  Future<void> getTransaksi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/transaksi.php'));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _listTransaksi = data['data'];
      } else {
        _listTransaksi = [];
      }
    } catch (e) {
      debugPrint("Error Get Transaksi: $e");
      _listTransaksi = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- BAGIAN INI SUDAH DITAMBAHKAN DEBUG LOGS ---
  Future<bool> simpanTransaksi({
    required String trxId,
    required double amount,
    required String namaKereta,
    required int jumlahPenumpang,
    required String asal,
    required String tujuan,
    required String tanggalBerangkat,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("--- MULAI KIRIM DATA TRANSAKSI KE SERVER ---");
      print("URL: $baseUrl/transaksi.php");
      print(
        "DATA: $trxId | $amount | $namaKereta | $jumlahPenumpang | $asal | $tujuan | $tanggalBerangkat",
      );

      final response = await http.post(
        Uri.parse('$baseUrl/transaksi.php'),
        body: {
          'id_transaksi': trxId,
          'total_harga': amount.toString(),
          'nama_kereta': namaKereta,
          'jumlah_penumpang': jumlahPenumpang.toString(),
          'stasiun_asal': asal,
          'stasiun_tujuan': tujuan,
          'tanggal_berangkat': tanggalBerangkat,
          'status': 'PAID',
        },
      );

      // --- DEBUG RESPONSE SERVER ---
      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");
      // ----------------------------

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        await getTransaksi();
        print("--- TRANSAKSI BERHASIL DISIMPAN ---");
        return true;
      } else {
        print("--- SERVER MERESPON GAGAL: ${data['message']} ---");
        return false;
      }
    } catch (e) {
      print("--- ERROR EXCEPTION (DART): $e ---");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
