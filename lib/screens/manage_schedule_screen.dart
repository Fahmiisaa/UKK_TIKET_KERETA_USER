import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import untuk format Rupiah

import '../providers/admin_provider.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  // --- Color Palette ---
  final Color navyPrimary = const Color(0xFF0A192F);
  final Color navyLight = const Color(0xFF172A45);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color bgLight = const Color(0xFFF5F7FA);
  final Color redError = const Color(0xFFEF4444);

  // --- Format Currency ---
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().getJadwal();
    });
  }

  // --- Delete Logic (Contoh) ---
  void _confirmDelete(String idJadwal) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Hapus Jadwal?"),
            content: const Text("Data yang dihapus tidak dapat dikembalikan."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Panggil fungsi delete di provider Anda
                  // context.read<AdminProvider>().deleteJadwal(idJadwal);
                },
                child: Text("Hapus", style: TextStyle(color: redError)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: navyPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Schedules',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body:
          adminProvider.isLoading
              ? Center(child: CircularProgressIndicator(color: goldAccent))
              : RefreshIndicator(
                onRefresh: () async => await adminProvider.getJadwal(),
                color: navyPrimary,
                child:
                    adminProvider.listJadwal.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: adminProvider.listJadwal.length,
                          separatorBuilder:
                              (ctx, i) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final schedule = adminProvider.listJadwal[index];
                            return _buildAdminCard(schedule);
                          },
                        ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: navyPrimary,
        onPressed: () {
          // Navigasi ke form tambah
        },
        icon: Icon(Icons.add, color: goldAccent),
        label: Text(
          "New Schedule",
          style: GoogleFonts.plusJakartaSans(
            color: goldAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No schedules found",
            style: GoogleFonts.plusJakartaSans(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(Map<String, dynamic> schedule) {
    // Parsing Data Aman
    final String id = schedule['id_jadwal']?.toString() ?? '0';
    final String namaKereta = schedule['nama_kereta'] ?? 'Unknown';
    final String hargaStr = schedule['harga']?.toString() ?? '0';
    final double harga = double.tryParse(hargaStr) ?? 0;

    final String asal = schedule['stasiun_asal'] ?? '-';
    final String tujuan = schedule['stasiun_tujuan'] ?? '-';
    final String jamBerangkat = schedule['jam_berangkat'] ?? '00:00';
    final String jamTiba = schedule['jam_tiba'] ?? '00:00';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: navyPrimary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- HEADER: Train Name & Price ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: navyPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.train_rounded,
                        color: navyPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaKereta,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: navyPrimary,
                          ),
                        ),
                        Text(
                          "ID: #$id", // Menampilkan ID untuk referensi admin
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  currencyFormatter.format(harga),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: goldAccent,
                  ),
                ),
              ],
            ),
          ),

          // --- BODY: Timeline Route ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // DEPARTURE
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jamBerangkat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: navyPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asal,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // VISUAL ARROW
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.grey.shade300,
                        size: 20,
                      ),
                      Text(
                        "Direct",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                // ARRIVAL
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        jamTiba,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: navyPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tujuan,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- FOOTER: Action Buttons ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Tambahkan logika Edit disini
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text("Edit"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navyPrimary,
                      side: BorderSide(color: navyPrimary.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmDelete(id),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redError,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
