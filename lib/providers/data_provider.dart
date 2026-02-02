import 'package:flutter/material.dart';
import '../models/train.dart';
import '../models/schedule.dart';
import '../models/booking.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class DataProvider with ChangeNotifier {
  // State Lists
  List<Train> _trains = [];
  List<Schedule> _schedules = [];
  List<Booking> _bookings = [];
  List<Transaction> _transactions = [];
  List<User> _customers = [];

  // UI States
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Train> get trains => _trains;
  List<Schedule> get schedules => _schedules;
  List<Booking> get bookings => _bookings;
  List<Transaction> get transactions => _transactions;
  List<User> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  // --- TRANSACTION & HISTORY ---

  Future<void> loadTransactionHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _apiService.getTransactionHistory();
    } catch (e) {
      _error = "Failed to load transaction history.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addLocalTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  // --- SCHEDULES (Database Masif Kereta Jawa) ---

  Future<void> loadSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mencoba mengambil data dari API
      final apiData = await _apiService.getSchedules();

      if (apiData.isEmpty) {
        _schedules = _generateFullJavaDatabase();
      } else {
        _schedules = apiData;
      }
    } catch (e) {
      // Fallback ke data lokal jika API error
      _schedules = _generateFullJavaDatabase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Schedule> _generateFullJavaDatabase() {
    final List<Schedule> db = [];
    // Simulasi untuk 3 hari ke depan
    final List<String> dates = ["2026-02-01", "2026-02-02", "2026-02-03"];

    for (var date in dates) {
      db.addAll([
        // RUTE: JAKARTA - SURABAYA (Jalur Utara)
        Schedule(
          id: 'GMR-SBI-01-$date',
          trainName: 'Argo Bromo Anggrek Luxury',
          departureStation: 'Gambir (GMR)',
          arrivalStation: 'Surabaya Pasarturi (SBI)',
          price: 1350000,
          departureTime: "08:20",
          arrivalTime: "16:30",
          duration: "8h 10m",
          date: date,
        ),
        Schedule(
          id: 'GMR-SBI-02-$date',
          trainName: 'Sembrani Eksekutif',
          departureStation: 'Gambir (GMR)',
          arrivalStation: 'Surabaya Pasarturi (SBI)',
          price: 650000,
          departureTime: "19:00",
          arrivalTime: "04:00",
          duration: "9h 00m",
          date: date,
        ),

        // RUTE: JAKARTA - YOGYAKARTA/SOLO (Jalur Selatan)
        Schedule(
          id: 'GMR-YK-01-$date',
          trainName: 'Taksaka Suite Class',
          departureStation: 'Gambir (GMR)',
          arrivalStation: 'Yogyakarta (YK)',
          price: 2150000,
          departureTime: "09:20",
          arrivalTime: "15:35",
          duration: "6h 15m",
          date: date,
        ),
        Schedule(
          id: 'GMR-SLO-01-$date',
          trainName: 'Argo Lawu Luxury',
          departureStation: 'Gambir (GMR)',
          arrivalStation: 'Solo Balapan (SLO)',
          price: 1250000,
          departureTime: "20:45",
          arrivalTime: "03:45",
          duration: "7h 00m",
          date: date,
        ),

        // RUTE: JAKARTA - MALANG
        Schedule(
          id: 'GMR-ML-01-$date',
          trainName: 'Gajayana Luxury',
          departureStation: 'Gambir (GMR)',
          arrivalStation: 'Malang (ML)',
          price: 1550000,
          departureTime: "18:50",
          arrivalTime: "07:10",
          duration: "12h 20m",
          date: date,
        ),
        Schedule(
          id: 'GMR-ML-02-$date',
          trainName: 'Brawijaya Eksekutif',
          departureStation: 'Gambir (GMR)',
          arrivalStation: 'Malang (ML)',
          price: 780000,
          departureTime: "15:40",
          arrivalTime: "05:00",
          duration: "13h 20m",
          date: date,
        ),

        // RUTE: BANDUNG - SURABAYA/SOLO
        Schedule(
          id: 'BD-SGU-01-$date',
          trainName: 'Argo Wilis Panoramic',
          departureStation: 'Bandung (BD)',
          arrivalStation: 'Surabaya Gubeng (SGU)',
          price: 1100000,
          departureTime: "07:40",
          arrivalTime: "17:35",
          duration: "9h 55m",
          date: date,
        ),
        Schedule(
          id: 'BD-SLO-01-$date',
          trainName: 'Lodaya Eksekutif',
          departureStation: 'Bandung (BD)',
          arrivalStation: 'Solo Balapan (SLO)',
          price: 450000,
          departureTime: "19:00",
          arrivalTime: "02:00",
          duration: "7h 00m",
          date: date,
        ),

        // RUTE: JAKARTA - BANDUNG (Short Haul)
        Schedule(
          id: 'GMR-BD-01-$date',
          trainName: 'Argo Parahyangan Excellence',
          departureStation: 'Gambir (GMR)',
          arrivalStation: 'Bandung (BD)',
          price: 250000,
          departureTime: "15:30",
          arrivalTime: "18:15",
          duration: "2h 45m",
          date: date,
        ),
      ]);
    }
    return db;
  }

  // --- BOOKING LOGIC ---

  Future<bool> createBooking(Booking booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBooking = await _apiService.createBooking(booking);
      _bookings.add(newBooking);

      final confirmedTrx = Transaction(
        id: "TRX-${newBooking.id}",
        amount: newBooking.totalPrice ?? 0,
        status: "paid",
        createdAt: DateTime.now(),
      );
      addLocalTransaction(confirmedTrx);

      return true;
    } catch (e) {
      _error = "Booking failed. Please try again.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- GENERIC CRUD ---

  Future<void> loadTrains() async {
    _isLoading = true;
    notifyListeners();
    try {
      _trains = await _apiService.getTrains();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomers() async {
    try {
      _customers = await _apiService.getCustomers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
