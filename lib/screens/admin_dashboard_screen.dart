import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'manage_train_screen.dart';
import 'manage_coach_seat_screen.dart';
import 'manage_schedule_screen.dart';
import 'admin_report_screen.dart';
import 'login_screen.dart'; //

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // --- Color Palette ---
  final Color navyPrimary = const Color(0xFF0A192F);
  final Color navyLight = const Color(0xFF172A45);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color bgLight = const Color(0xFFF5F7FA);
  final Color textGrey = const Color(0xFF64748B);
  final Color redError = const Color(0xFFEF4444);

  // --- LOGIC: LOGOUT (DIPERBAIKI) ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // User harus memilih tombol, tidak bisa klik luar
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: navyPrimary, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Konfirmasi",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: navyPrimary,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Text(
              "Apakah Anda yakin ingin keluar dari aplikasi? Anda harus login kembali untuk masuk.",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: [
              // Tombol Batal
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  "Batal",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: textGrey,
                  ),
                ),
              ),
              // Tombol Keluar
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);

                  // --- NAVIGASI KE LOGIN ---
                  // pushAndRemoveUntil menghapus riwayat back button
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: redError,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  "Keluar",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER SECTION
            _buildHeader(context),

            // 2. STATS OVERVIEW
            Transform.translate(
              offset: const Offset(0, -40),
              child: _buildStatsRow(),
            ),

            // 3. MAIN MENU GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Management Menu",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: navyPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuGrid(context),

                  const SizedBox(height: 30),

                  // 4. RECENT ACTIVITY
                  Text(
                    "Recent Bookings",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: navyPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildRecentActivityList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: goldAccent,
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
      ),
    );
  }

  // --- WIDGET: HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 60),
      decoration: BoxDecoration(
        color: navyPrimary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        image: DecorationImage(
          image: const NetworkImage(
            "https://www.transparenttextures.com/patterns/cubes.png",
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            navyPrimary.withOpacity(0.9),
            BlendMode.darken,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kiri: Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Hello, Admin 👋",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Kanan: Tombol Logout & Profil
          Row(
            children: [
              // TOMBOL LOGOUT
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: "Logout",
                ),
              ),
              const SizedBox(width: 12),

              // Profil Image
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: goldAccent, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET: STATS ROW ---
  Widget _buildStatsRow() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildStatCard(
            "Total Revenue",
            "IDR 124M",
            Icons.monetization_on_outlined,
            goldAccent,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            "Tickets Sold",
            "1,240",
            Icons.confirmation_number_outlined,
            Colors.blueAccent,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            "Active Trains",
            "8",
            Icons.train_outlined,
            Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: navyPrimary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: navyPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textGrey),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: MENU GRID ---
  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _buildMenuCard(
          context,
          title: "Manage Trains",
          icon: Icons.train_rounded,
          color: const Color(0xFF4A90E2),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageTrainScreen()),
              ),
        ),
        _buildMenuCard(
          context,
          title: "Manage Coach",
          icon: Icons.chair_alt_rounded,
          color: const Color(0xFF50E3C2),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageCoachScreen()),
              ),
        ),
        _buildMenuCard(
          context,
          title: "Schedules",
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFFFFB156),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageScheduleScreen()),
              ),
        ),
        _buildMenuCard(
          context,
          title: "Reports & Data",
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFFFF5F5F),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminReportScreen()),
              ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: navyPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: RECENT ACTIVITY ---
  Widget _buildRecentActivityList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_long_rounded, color: textGrey),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Booking #INV-00${index + 84}",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: navyPrimary,
                      ),
                    ),
                    Text(
                      "Argo Bromo Anggrek • 2 Seats",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Just now",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: textGrey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
