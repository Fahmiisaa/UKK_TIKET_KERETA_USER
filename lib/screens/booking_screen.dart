import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../models/transaction.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- DATA VARIABLES ---
  dynamic _departureSchedule;
  dynamic _returnSchedule;

  DateTime? _departureDate;
  DateTime? _returnDate;

  bool _isRoundTrip = false;
  int _passengerCount = 1;

  // Seat Selection
  List<String> _selectedSeats = [];

  // --- DEMO MODE: LIST KOSONG AGAR SEMUA KURSI BISA DIPILIH ---
  final List<String> _bookedSeatsMock = [];

  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _idControllers = [TextEditingController()];

  // --- COLORS ---
  final Color navyBlue = const Color(0xFF0A192F);
  final Color navyLight = const Color(0xFF172A45);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color softBg = const Color(0xFFF0F4F8);
  final Color slateGrey = const Color(0xFF64748B);
  final Color successGreen = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().getJadwal();
    });
  }

  // --- LOGIC: PROCESS CHECKOUT ---
  void _processPayment() async {
    // 1. Validasi Input
    if (_departureDate == null) {
      _showSnackBar("Please select departure date.", isError: true);
      return;
    }
    if (_departureSchedule == null) {
      _showSnackBar("Please select departure train.", isError: true);
      return;
    }
    if (_isRoundTrip) {
      if (_returnDate == null) {
        _showSnackBar("Please select return date.", isError: true);
        return;
      }
      if (_returnSchedule == null) {
        _showSnackBar("Please select return train.", isError: true);
        return;
      }
    }
    if (_selectedSeats.length != _passengerCount) {
      _showSnackBar(
        "Please select seats for $_passengerCount passengers.",
        isError: true,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    // 2. Hitung Total
    final double depPrice =
        double.tryParse(_departureSchedule['harga'].toString()) ?? 0;
    final double retPrice =
        _isRoundTrip
            ? (double.tryParse(_returnSchedule?['harga'].toString() ?? '0') ??
                0)
            : 0;

    final double totalAmount = (depPrice + retPrice) * _passengerCount;
    final String trxId =
        "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    // 3. Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) =>
              Center(child: CircularProgressIndicator(color: goldAccent)),
    );

    // 4. Call Provider (Simpan ke DB & State History)
    // Pastikan function simpanTransaksi di Provider Anda mengembalikan boolean success
    final bool isSuccess = await context.read<AdminProvider>().simpanTransaksi(
      trxId: trxId,
      amount: totalAmount,
      namaKereta: _departureSchedule['nama_kereta'] ?? "Unknown",
      jumlahPenumpang: _passengerCount,
      asal: _departureSchedule['stasiun_asal'] ?? "Unknown",
      tujuan: _departureSchedule['stasiun_tujuan'] ?? "Unknown",
      tanggalBerangkat: DateFormat('yyyy-MM-dd').format(_departureDate!),
    );

    if (mounted) Navigator.pop(context); // Close Loading

    if (isSuccess) {
      // Buat objek transaksi lokal untuk ditampilkan di struk
      final newTransaction = Transaction(
        id: trxId,
        amount: totalAmount,
        status: "paid",
        createdAt: DateTime.now(),
      );
      _showReceiptDialog(newTransaction);
    } else {
      _showSnackBar("Transaction failed. Please try again.", isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : navyBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: softBg,
      appBar: _buildAppBar(),
      body:
          adminProvider.isLoading
              ? Center(child: CircularProgressIndicator(color: goldAccent))
              : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Trip Itinerary", Icons.map),
                        const SizedBox(height: 16),
                        _buildItineraryCard(adminProvider),

                        const SizedBox(height: 24),

                        _buildSectionHeader("Passenger Details", Icons.people),
                        const SizedBox(height: 16),
                        _buildPassengerControl(),
                        const SizedBox(height: 16),
                        _buildSeatSelectionCard(),

                        const SizedBox(height: 24),

                        if (_selectedSeats.length == _passengerCount) ...[
                          _buildSectionHeader(
                            "Identity Information",
                            Icons.badge,
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            _passengerCount,
                            (index) => _buildPassengerForm(index),
                          ),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
      bottomSheet: _buildBottomCheckout(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: navyBlue,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: goldAccent, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'EXECU-TICKETING',
        style: GoogleFonts.cinzel(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: navyBlue, size: 20),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: navyBlue,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryCard(AdminProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: navyBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, isDeparture: true),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Departure Date",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: slateGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: navyBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _departureDate != null
                                  ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(_departureDate!)
                                  : "Select Date",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color:
                                    _departureDate == null
                                        ? Colors.redAccent
                                        : navyBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Round Trip?",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: slateGrey,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Switch(
                          value: _isRoundTrip,
                          activeColor: goldAccent,
                          onChanged: (v) {
                            setState(() {
                              _isRoundTrip = v;
                              if (!v) {
                                _returnSchedule = null;
                                _returnDate = null;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          _buildTrainSelectorTile(
            label: "Departure Train",
            schedule: _departureSchedule,
            date: _departureDate,
            onTap: () {
              if (_departureDate == null) {
                _showSnackBar(
                  "Please select departure date first!",
                  isError: true,
                );
              } else {
                _showSchedulePicker(
                  provider,
                  isReturn: false,
                  selectedDate: _departureDate!,
                );
              }
            },
          ),

          if (_isRoundTrip) ...[
            const Divider(height: 1, thickness: 4, color: Color(0xFFF0F4F8)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: () => _selectDate(context, isDeparture: false),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: navyBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Return Date",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: slateGrey,
                          ),
                        ),
                        Text(
                          _returnDate != null
                              ? DateFormat('dd MMM yyyy').format(_returnDate!)
                              : "Select Return Date",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                _returnDate == null
                                    ? Colors.redAccent
                                    : navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            _buildTrainSelectorTile(
              label: "Return Train",
              schedule: _returnSchedule,
              date: _returnDate,
              onTap: () {
                if (_returnDate == null) {
                  _showSnackBar(
                    "Please select return date first!",
                    isError: true,
                  );
                } else {
                  _showSchedulePicker(
                    provider,
                    isReturn: true,
                    selectedDate: _returnDate!,
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrainSelectorTile({
    required String label,
    required dynamic schedule,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final bool isEnabled = date != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEnabled ? softBg : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.train_outlined,
                color: isEnabled ? navyBlue : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 12, color: slateGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule != null
                        ? (schedule['nama_kereta'] ?? 'Unknown')
                        : "Select Train",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: schedule != null ? navyBlue : Colors.grey.shade400,
                    ),
                  ),
                  if (schedule != null)
                    Text(
                      "${schedule['jam_berangkat']} - ${schedule['jam_tiba']}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: goldAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isEnabled ? slateGrey : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Passengers",
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
              Text(
                "$_passengerCount Person(s)",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _circleBtn(Icons.remove, () {
                if (_passengerCount > 1) {
                  setState(() {
                    _passengerCount--;
                    _nameControllers.removeLast();
                    _idControllers.removeLast();
                    _selectedSeats.clear();
                  });
                }
              }),
              const SizedBox(width: 12),
              _circleBtn(Icons.add, () {
                if (_passengerCount < 4) {
                  setState(() {
                    _passengerCount++;
                    _nameControllers.add(TextEditingController());
                    _idControllers.add(TextEditingController());
                    _selectedSeats.clear();
                  });
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildSeatSelectionCard() {
    bool isComplete = _selectedSeats.length == _passengerCount;
    return InkWell(
      onTap: () {
        if (_departureSchedule == null) {
          _showSnackBar("Please select departure train first.");
          return;
        }
        if (_isRoundTrip && _returnSchedule == null) {
          _showSnackBar("Please select return train first.");
          return;
        }
        _showSeatSelectionModal();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isComplete ? successGreen : goldAccent.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_seat,
                  color: isComplete ? successGreen : goldAccent,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? "Seats Selected" : "Select Seat Numbers",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: navyBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedSeats.isEmpty
                          ? "Required"
                          : _selectedSeats.join(", "),
                      style: GoogleFonts.inter(fontSize: 12, color: slateGrey),
                    ),
                  ],
                ),
              ],
            ),
            if (isComplete)
              const Icon(Icons.check_circle, color: Color(0xFF10B981))
            else
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSeatSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.8,
            maxChildSize: 0.95,
            builder:
                (_, controller) => Container(
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 4,
                              width: 40,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Select Seats",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: navyBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _legendItem(Colors.white, "Available", true),
                                const SizedBox(width: 16),
                                _legendItem(navyBlue, "Selected", false),
                                const SizedBox(width: 16),
                                _legendItem(
                                  Colors.grey.shade300,
                                  "Booked",
                                  false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: controller,
                          padding: const EdgeInsets.all(24),
                          children: [
                            _buildWagonLabel("EXECUTIVE WAGON 1"),
                            _buildSeatGrid(),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: CustomButton(
                          text:
                              "Confirm Seats (${_selectedSeats.length}/$_passengerCount)",
                          onPressed: () {
                            if (_selectedSeats.length != _passengerCount) {
                              _showSnackBar(
                                "Please select $_passengerCount seats!",
                              );
                            } else {
                              Navigator.pop(context);
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _legendItem(Color color, String label, bool border) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: border ? Border.all(color: Colors.grey.shade300) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: slateGrey)),
      ],
    );
  }

  Widget _buildWagonLabel(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: navyLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: goldAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.0,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
      ),
      itemCount: 40,
      itemBuilder: (context, index) {
        int row = (index / 5).floor() + 1;
        int colIndex = index % 5;
        if (colIndex == 2)
          return Center(
            child: Text("$row", style: TextStyle(color: Colors.grey[300])),
          );

        String colChar =
            colIndex == 0
                ? 'A'
                : colIndex == 1
                ? 'B'
                : colIndex == 3
                ? 'C'
                : 'D';
        String seatId = "$colChar$row";
        bool isBooked = _bookedSeatsMock.contains(seatId);
        bool isSelected = _selectedSeats.contains(seatId);

        return InkWell(
          onTap: isBooked ? null : () => _toggleSeat(seatId),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? navyBlue
                      : (isBooked ? Colors.grey.shade300 : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border:
                  isSelected || isBooked
                      ? null
                      : Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                seatId,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected
                          ? goldAccent
                          : (isBooked ? Colors.white : navyBlue),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleSeat(String seatId) {
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        if (_selectedSeats.length < _passengerCount) {
          _selectedSeats.add(seatId);
        } else {
          _selectedSeats.removeAt(0);
          _selectedSeats.add(seatId);
        }
      }
    });
  }

  Widget _buildPassengerForm(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Passenger ${index + 1}",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: navyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Seat: ${_selectedSeats.length > index ? _selectedSeats[index] : '-'}",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: navyBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // NAME INPUT
          TextFormField(
            controller: _nameControllers[index],
            style: GoogleFonts.inter(
              color: navyBlue,
              fontWeight: FontWeight.w600,
            ), // Text Color
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: GoogleFonts.inter(color: slateGrey),
              filled: true,
              fillColor: softBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (val) => val!.isEmpty ? "Name required" : null,
          ),
          const SizedBox(height: 12),
          // NIK INPUT
          TextFormField(
            controller: _idControllers[index],
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(
              color: navyBlue,
              fontWeight: FontWeight.bold,
            ), // Text Color
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'ID Number is required';
              if (value.length < 5) return 'ID Invalid';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'ID Number (NIK/Passport)',
              labelStyle: GoogleFonts.inter(color: slateGrey),
              filled: true,
              fillColor: softBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.credit_card, color: navyBlue, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout() {
    final double depPrice =
        double.tryParse(_departureSchedule?['harga'].toString() ?? '0') ?? 0;
    final double retPrice =
        _isRoundTrip
            ? (double.tryParse(_returnSchedule?['harga'].toString() ?? '0') ??
                0)
            : 0;
    final double total = (depPrice + retPrice) * _passengerCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Payment",
                  style: GoogleFonts.inter(fontSize: 12, color: slateGrey),
                ),
                Text(
                  "Rp ${NumberFormat('#,###').format(total)}",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            height: 50,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                "Checkout",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: goldAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SHOW SCHEDULE LIST MODAL ---
  void _showSchedulePicker(
    AdminProvider provider, {
    required bool isReturn,
    required DateTime selectedDate,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            builder:
                (context, scrollController) => _SchedulePickerModal(
                  adminProvider: provider,
                  scrollController: scrollController,
                  selectedDateDisplay: selectedDate,
                  onSelected: (schedule) {
                    setState(
                      () =>
                          isReturn
                              ? _returnSchedule = schedule
                              : _departureSchedule = schedule,
                    );
                    Navigator.pop(context);
                  },
                ),
          ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isDeparture,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isDeparture
              ? (_departureDate ?? DateTime.now())
              : (_returnDate ?? _departureDate ?? DateTime.now()),
      firstDate:
          isDeparture ? DateTime.now() : (_departureDate ?? DateTime.now()),
      lastDate: DateTime(2027),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: navyBlue,
                onPrimary: goldAccent,
                onSurface: navyBlue,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          if (_returnDate != null && picked.isAfter(_returnDate!)) {
            _returnDate = null;
            _returnSchedule = null;
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  // --- RECEIPT DIALOG (Connects to History) ---
  void _showReceiptDialog(Transaction trx) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  "Booking Successful!",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: navyBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "E-Ticket has been issued.",
                  style: GoogleFonts.inter(color: slateGrey, fontSize: 12),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Trx ID:",
                            style: GoogleFonts.inter(
                              color: slateGrey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            trx.id,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: navyBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total:",
                            style: GoogleFonts.inter(
                              color: slateGrey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Rp ${NumberFormat('#,###').format(trx.amount)}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Tutup Dialog
                    Navigator.pop(
                      context,
                    ); // Tutup Booking Screen -> Kembali ke Dashboard/History
                  },
                  child: Text(
                    "VIEW HISTORY",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: goldAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

// --- SUB-WIDGET: SCHEDULE LIST ---
class _SchedulePickerModal extends StatelessWidget {
  final AdminProvider adminProvider;
  final ScrollController scrollController;
  final DateTime selectedDateDisplay;
  final Function(dynamic) onSelected;

  final Color navyBlue = const Color(0xFF0A192F);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color slateGrey = const Color(0xFF64748B);

  const _SchedulePickerModal({
    super.key,
    required this.adminProvider,
    required this.scrollController,
    required this.onSelected,
    required this.selectedDateDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final list = adminProvider.listJadwal;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  "Select Train Schedule",
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: navyBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: navyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Date: ${DateFormat('EEEE, dd MMM yyyy').format(selectedDateDisplay)}",
                    style: GoogleFonts.inter(
                      color: navyBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                list.isEmpty
                    ? Center(
                      child: Text(
                        "No schedule available",
                        style: GoogleFonts.inter(color: slateGrey),
                      ),
                    )
                    : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      itemCount: list.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final double harga =
                            double.tryParse(item['harga']?.toString() ?? '0') ??
                            0;
                        return InkWell(
                          onTap: () => onSelected(item),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: navyBlue.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_train,
                                  color: navyBlue,
                                  size: 40,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama_kereta'] ?? '-',
                                        style: GoogleFonts.cinzel(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: navyBlue,
                                        ),
                                      ),
                                      Text(
                                        "${item['stasiun_asal']} ➔ ${item['stasiun_tujuan']}",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: slateGrey,
                                        ),
                                      ),
                                      Text(
                                        "${item['jam_berangkat']} - ${item['jam_tiba']}",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: slateGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${(harga / 1000).toStringAsFixed(0)}k",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: goldAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
