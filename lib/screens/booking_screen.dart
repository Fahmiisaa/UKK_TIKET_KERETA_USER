import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/data_provider.dart';
import '../models/schedule.dart';
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
  Schedule? _selectedSchedule;
  Schedule? _returnSchedule;
  int _passengerCount = 1;

  DateTime _departureDate = DateTime.now();
  DateTime? _returnDate;
  bool _isRoundTrip = false;

  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _idControllers = [TextEditingController()];
  final List<String> _passengerTypes = ['Adult'];

  // COLORS - Kept same, but utilized better
  final Color navyBlue = const Color(0xFF0A192F);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color softBg = const Color(0xFFF8FAFC);
  final Color slateGrey = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadSchedules();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isDeparture
              ? _departureDate
              : (_returnDate ?? _departureDate.add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyBlue,
              onPrimary: goldAccent,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(_departureDate)) {
            _returnDate = null;
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _processPayment() {
    if (_selectedSchedule == null) {
      _showSnackBar("Please select a departure schedule");
      return;
    }
    if (_isRoundTrip) {
      if (_returnSchedule == null) {
        _showSnackBar("Please select a return schedule");
        return;
      }
      if (_returnDate == null) {
        _showSnackBar("Please select a return date");
        return;
      }
    }
    if (!_formKey.currentState!.validate()) return;

    final double departurePrice = _selectedSchedule!.price * _passengerCount;
    final double returnPrice =
        _isRoundTrip ? (_returnSchedule!.price * _passengerCount) : 0;
    final double totalAmount = departurePrice + returnPrice;

    final newTransaction = Transaction(
      id: "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      amount: totalAmount,
      status: "paid",
      createdAt: DateTime.now(),
    );

    context.read<DataProvider>().addLocalTransaction(newTransaction);
    _showReceiptDialog(newTransaction);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: navyBlue,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: goldAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EXECU-TICKETING',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.w700, // Slightly lighter for elegance
            color: Colors.white, // White text pops better on Navy
            letterSpacing: 1.5,
            fontSize: 20,
          ),
        ),
        actions: [
          // Added a placeholder action to balance the app bar
          IconButton(
            icon: Icon(Icons.notifications_none, color: goldAccent),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopBanner(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ), // Increased padding
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel("Your Trip"),
                      const SizedBox(height: 16), // Increased spacing
                      _buildScheduleSelector(dataProvider),
                      const SizedBox(height: 20),
                      _buildTripConfiguration(),
                      const SizedBox(height: 32),
                      _buildSectionLabel("Passenger Details"),
                      const SizedBox(height: 16),
                      _buildPassengerCounter(),
                      ...List.generate(
                        _passengerCount,
                        (index) => _buildPassengerCard(index),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildTripConfiguration() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.swap_vert_circle,
                  color: _isRoundTrip ? navyBlue : slateGrey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "Round Trip",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isRoundTrip ? navyBlue : slateGrey,
                  ),
                ),
              ],
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _isRoundTrip,
                activeColor: Colors.white,
                activeTrackColor: goldAccent,
                inactiveThumbColor: slateGrey,
                inactiveTrackColor: Colors.grey.shade200,
                onChanged:
                    (v) => setState(() {
                      _isRoundTrip = v;
                      if (!v) {
                        _returnDate = null;
                        _returnSchedule = null;
                      }
                    }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateTile(
                "Departure",
                _departureDate,
                false,
                () => _selectDate(context, true),
              ),
            ),
            if (_isRoundTrip) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTile(
                  "Return",
                  _returnDate,
                  _returnDate == null,
                  () => _selectDate(context, false),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDateTile(
    String label,
    DateTime? date,
    bool isPlaceholder,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Clean shadow instead of hard border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                isPlaceholder ? Colors.transparent : navyBlue.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: slateGrey,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: goldAccent),
                const SizedBox(width: 10),
                Text(
                  date == null
                      ? "Select Date"
                      : "${date.day}/${date.month}/${date.year}",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        isPlaceholder ? slateGrey.withOpacity(0.5) : navyBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSelector(DataProvider dataProvider) {
    return Column(
      children: [
        _buildScheduleItem(
          label: "Departure Train",
          selected: _selectedSchedule,
          onTap: () => _showSchedulePicker(dataProvider, false),
        ),
        if (_isRoundTrip) ...[
          const SizedBox(height: 16),
          _buildScheduleItem(
            label: "Return Train",
            selected: _returnSchedule,
            onTap: () => _showSchedulePicker(dataProvider, true),
          ),
        ],
      ],
    );
  }

  Widget _buildScheduleItem({
    required String label,
    required Schedule? selected,
    required VoidCallback onTap,
  }) {
    bool isSelected = selected != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border:
              isSelected
                  ? Border.all(color: goldAccent.withOpacity(0.5), width: 1.5)
                  : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? navyBlue : softBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.train,
                color: isSelected ? goldAccent : slateGrey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child:
                  selected == null
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              color: navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Tap to select schedule",
                            style: GoogleFonts.inter(
                              color: slateGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected.trainName,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: navyBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "${selected.departureStation} ➔ ${selected.arrivalStation}",
                                style: GoogleFonts.inter(
                                  color: slateGrey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: slateGrey.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // _showSchedulePicker Implementation remains structurally the same, see styling in _SchedulePickerModal class

  void _showSchedulePicker(DataProvider dataProvider, bool isReturn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => _SchedulePickerModal(
                  dataProvider: dataProvider,
                  scrollController: scrollController,
                  onSelected: (schedule) {
                    setState(() {
                      if (isReturn) {
                        _returnSchedule = schedule;
                      } else {
                        _selectedSchedule = schedule;
                      }
                    });
                    Navigator.pop(context);
                  },
                  navyBlue: navyBlue,
                  goldAccent: goldAccent,
                  slateGrey: slateGrey,
                ),
          ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      height: 24,
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: navyBlue, // Changed to Navy for better contrast
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPassengerCounter() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: navyBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Passengers",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                "Select total seats",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _counterButton(Icons.remove, _decrementPassenger),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_passengerCount',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: goldAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _counterButton(Icons.add, _incrementPassenger),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback action) => InkWell(
    onTap: action,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white, // White button for contrast
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: navyBlue, size: 16),
    ),
  );

  void _incrementPassenger() {
    if (_passengerCount < 4) {
      setState(() {
        _passengerCount++;
        _nameControllers.add(TextEditingController());
        _idControllers.add(TextEditingController());
        _passengerTypes.add('Adult');
      });
    }
  }

  void _decrementPassenger() {
    if (_passengerCount > 1) {
      setState(() {
        _passengerCount--;
        _nameControllers.removeLast().dispose();
        _idControllers.removeLast().dispose();
        _passengerTypes.removeLast();
      });
    }
  }

  Widget _buildPassengerCard(int index) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: softBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, size: 16, color: slateGrey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "PASSENGER ${index + 1}",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: navyBlue,
                    ),
                  ),
                ],
              ),
              _buildTypeToggle(index),
            ],
          ),
          const SizedBox(height: 20),
          // Assuming CustomTextField is available, styling via textTheme or passing style
          // Since I can't see CustomTextField code, I assume it accepts standard params
          CustomTextField(
            controller: _nameControllers[index],
            labelText: 'Full Name',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _idControllers[index],
            labelText: 'ID / NIK Number',
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(int index) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children:
            ['Adult', 'Child'].map((t) {
              bool active = _passengerTypes[index] == t;
              return GestureDetector(
                onTap: () => setState(() => _passengerTypes[index] = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active ? navyBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow:
                        active
                            ? [
                              BoxShadow(
                                color: navyBlue.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ]
                            : [],
                  ),
                  child: Text(
                    t,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: active ? goldAccent : slateGrey,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildBottomAction() {
    final double departurePrice =
        (_selectedSchedule?.price ?? 0) * _passengerCount;
    final double returnPrice =
        _isRoundTrip ? ((_returnSchedule?.price ?? 0) * _passengerCount) : 0;
    final double total = departurePrice + returnPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                  "Total Price",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: slateGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Rp ${total.toStringAsFixed(0)}",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            height: 50, // Fixed height for button
            child: CustomButton(text: 'Checkout', onPressed: _processPayment),
          ),
        ],
      ),
    );
  }

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
            title: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Payment Successful",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
            content: Text(
              "Ticket Issued Successfully.\nTRX ID: ${trx.id}",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: slateGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "DONE",
                      style: TextStyle(
                        color: navyBlue,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _SchedulePickerModal extends StatefulWidget {
  final DataProvider dataProvider;
  final ScrollController scrollController;
  final Function(Schedule) onSelected;
  final Color navyBlue;
  final Color goldAccent;
  final Color slateGrey;

  const _SchedulePickerModal({
    required this.dataProvider,
    required this.scrollController,
    required this.onSelected,
    required this.navyBlue,
    required this.goldAccent,
    required this.slateGrey,
  });

  @override
  State<_SchedulePickerModal> createState() => _SchedulePickerModalState();
}

class _SchedulePickerModalState extends State<_SchedulePickerModal> {
  String _query = "";
  String _class = "All";

  @override
  Widget build(BuildContext context) {
    final list =
        widget.dataProvider.schedules.where((s) {
          final mQuery =
              s.trainName.toLowerCase().contains(_query.toLowerCase()) ||
              s.departureStation.toLowerCase().contains(_query.toLowerCase()) ||
              s.arrivalStation.toLowerCase().contains(_query.toLowerCase());
          final mClass =
              _class == "All" ||
              (_class == "Business" && s.price < 400000) ||
              (_class == "Platinum" && s.price >= 400000);
          return mQuery && mClass;
        }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Route",
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: widget.navyBlue,
                  ),
                ),
                const SizedBox(height: 20),
                // Search Field - Polished
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: GoogleFonts.inter(
                      color: widget.navyBlue,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search your destination...",
                      hintStyle: GoogleFonts.inter(
                        color: widget.slateGrey.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: widget.goldAccent),
                      filled: true,
                      fillColor: Colors.transparent, // Handled by container
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Chips - Polished
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        ["All", "Business", "Platinum"].map((c) {
                          bool sel = _class == c;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(c),
                              selected: sel,
                              onSelected: (_) => setState(() => _class = c),
                              selectedColor: widget.navyBlue,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              labelStyle: GoogleFonts.inter(
                                color:
                                    sel ? widget.goldAccent : widget.slateGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // No hard border, maybe shadow instead or clear logic
                              side: BorderSide(
                                color:
                                    sel
                                        ? Colors.transparent
                                        : Colors.grey.shade200,
                                width: 1,
                              ),
                              elevation: sel ? 4 : 0,
                              pressElevation: 0,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final s = list[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.navyBlue.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => widget.onSelected(s),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.trainName,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w800,
                                      color: widget.navyBlue,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.goldAccent.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      s.price >= 400000
                                          ? "PLATINUM CLASS"
                                          : "BUSINESS CLASS",
                                      style: GoogleFonts.inter(
                                        color: widget.navyBlue,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Rp ${s.price.toStringAsFixed(0)}",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w900,
                                  color: widget.navyBlue,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(height: 1, thickness: 0.5),
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  // Departure Dot
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: widget.goldAccent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  // Line
                                  Container(
                                    width: 1.5,
                                    height: 30,
                                    color: Colors.grey[300],
                                  ),
                                  // Arrival Pin
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: widget.navyBlue,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    // Departure Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          s.departureStation,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: widget.navyBlue,
                                          ),
                                        ),
                                        Text(
                                          s.departureTime,
                                          style: GoogleFonts.inter(
                                            color: widget.slateGrey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          s.arrivalStation,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: widget.navyBlue,
                                          ),
                                        ),
                                        Text(
                                          "Est. Arrival",
                                          style: GoogleFonts.inter(
                                            color: widget.slateGrey.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
