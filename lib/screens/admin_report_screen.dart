import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen>
    with SingleTickerProviderStateMixin {
  // --- Color Palette (Sama dengan Dashboard) ---
  final Color navyPrimary = const Color(0xFF0A192F);
  final Color navyLight = const Color(0xFF172A45);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color bgLight = const Color(0xFFF5F7FA);
  final Color textGrey = const Color(0xFF64748B);
  final Color greenSuccess = const Color(0xFF22C55E);

  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: navyPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Financial Reports',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: goldAccent,
          indicatorWeight: 3,
          labelColor: goldAccent,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Transaction History'),
            Tab(text: 'Revenue Analysis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTransactionHistory(), _buildMonthlyRevenue()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aksi Download PDF/Excel
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Downloading Report for ${DateFormat('MMM yyyy').format(_selectedDate)}...",
              ),
            ),
          );
        },
        backgroundColor: navyPrimary,
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        label: Text(
          "Export Data",
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
      ),
    );
  }

  // --- TAB 1: LIST TRANSAKSI ---
  Widget _buildTransactionHistory() {
    return Column(
      children: [
        _buildDatePicker(),
        Expanded(
          child: ListView.builder(
            itemCount: 8, // Dummy Data
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemBuilder: (context, index) {
              return _buildTransactionCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(int index) {
    // Dummy Logic untuk variasi data
    bool isSuccess = index % 3 != 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isSuccess
                      ? navyPrimary.withOpacity(0.05)
                      : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              color: isSuccess ? navyPrimary : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INV-TRAIN-00${index + 120}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: navyPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Argo Bromo • Budi Santoso',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd MMM yyyy, HH:mm',
                  ).format(DateTime.now().subtract(Duration(hours: index * 5))),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'IDR 750.000',
                style: GoogleFonts.plusJakartaSans(
                  color: isSuccess ? greenSuccess : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isSuccess
                          ? greenSuccess.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isSuccess ? 'Paid' : 'Pending',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? greenSuccess : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 2: ANALISIS PENDAPATAN ---
  Widget _buildMonthlyRevenue() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Overview ${DateFormat('MMMM yyyy').format(_selectedDate)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: navyPrimary,
                ),
              ),
              IconButton(
                onPressed: _pickDate,
                icon: Icon(Icons.calendar_month_rounded, color: navyPrimary),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Kartu Total Pendapatan (Gradient Navy)
          _buildRevenueSummaryCard(),

          const SizedBox(height: 25),

          // Bagian Statistik Chart
          Text(
            'Income Statistics',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: navyPrimary,
            ),
          ),
          const SizedBox(height: 15),
          _buildChartSimulation(), // Custom simple chart

          const SizedBox(height: 25),

          // Detail Breakdown
          Text(
            'Performance Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: navyPrimary,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  "Tickets Sold",
                  "1,250",
                  Icons.confirmation_number_outlined,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDetailCard(
                  "Occupancy",
                  "88%",
                  Icons.pie_chart_outline,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 80), // Space untuk FAB
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildDatePicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Date:',
            style: GoogleFonts.plusJakartaSans(
              color: textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          InkWell(
            onTap: _pickDate,
            child: Row(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: navyPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: navyPrimary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [navyPrimary, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: navyPrimary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Total Revenue',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'IDR 124.500.000',
            style: GoogleFonts.plusJakartaSans(
              color: goldAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '+15% from last month',
            style: GoogleFonts.plusJakartaSans(
              color: greenSuccess,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSimulation() {
    // Simulasi Chart Batang Sederhana menggunakan Row dan Container
    final List<double> values = [
      0.4,
      0.6,
      0.3,
      0.8,
      0.5,
      0.9,
      0.7,
    ]; // Persentase tinggi
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 12, // Lebar batang
                height: 140 * values[index], // Tinggi dinamis
                decoration: BoxDecoration(
                  color:
                      index == 5
                          ? goldAccent
                          : navyPrimary.withOpacity(
                            0.2,
                          ), // Highlight hari Sabtu
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                days[index],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDetailCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: navyPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(color: textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: navyPrimary,
              onPrimary: Colors.white,
              onSurface: navyPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
