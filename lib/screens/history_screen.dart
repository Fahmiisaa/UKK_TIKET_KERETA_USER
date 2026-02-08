import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil data dari API saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().getTransaksi();
    });
  }

  // --- COLORS (Konsisten dengan Booking Screen) ---
  final Color navyBlue = const Color(0xFF0A192F);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color softBg = const Color(0xFFF0F4F8);
  final Color slateGrey = const Color(0xFF64748B);
  final Color successGreen = const Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: navyBlue,
        title: Text(
          "MY BOOKINGS",
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        // Tombol refresh manual di AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<AdminProvider>().getTransaksi(),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          // 1. Loading State
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: goldAccent));
          }

          final history = provider.listTransaksi;

          // 2. Empty State
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No transactions found",
                    style: GoogleFonts.inter(color: slateGrey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => provider.getTransaksi(),
                    child: Text(
                      "Refresh Data",
                      style: TextStyle(color: navyBlue),
                    ),
                  ),
                ],
              ),
            );
          }

          // 3. List Data State
          return RefreshIndicator(
            onRefresh: () => provider.getTransaksi(),
            color: navyBlue,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                // Ambil data item (Map dari JSON)
                final item = history[index];
                return _buildTicketCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(dynamic item) {
    // Parsing Data dengan Safety Check (mencegah error null)
    final String trxId = item['id_transaksi'] ?? 'Unknown ID';
    final String status = item['status'] ?? 'PENDING';
    final String namaKereta = item['nama_kereta'] ?? 'Unknown Train';
    final String asal = item['stasiun_asal'] ?? '-';
    final String tujuan = item['stasiun_tujuan'] ?? '-';
    final String tglRaw =
        item['tanggal_berangkat'] ?? DateTime.now().toString();
    final String jumlahPenumpang = item['jumlah_penumpang']?.toString() ?? '1';

    // Parsing Harga
    final double totalHarga =
        double.tryParse(item['total_harga']?.toString() ?? '0') ?? 0;

    // Parsing Tanggal agar rapi (Contoh: 2026-02-08 -> 08 Feb 2026)
    String displayDate = tglRaw;
    try {
      DateTime dt = DateTime.parse(tglRaw);
      displayDate = DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      // Jika format tanggal dari API aneh, biarkan raw stringnya
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: navyBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER: ID & STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: navyBlue.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, size: 16, color: navyBlue),
                    const SizedBox(width: 8),
                    Text(
                      trxId,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: navyBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        status == 'PAID'
                            ? successGreen.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: status == 'PAID' ? successGreen : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: status == 'PAID' ? successGreen : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BODY: RUTE & DETAIL
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RUTE (Asal -> Tujuan)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ORIGIN",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: slateGrey,
                            ),
                          ),
                          Text(
                            asal,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_right_alt, color: goldAccent, size: 30),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "DESTINATION",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: slateGrey,
                            ),
                          ),
                          Text(
                            tujuan,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // DETAIL GRID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _detailItem(Icons.train, "Train", namaKereta),
                    _detailItem(Icons.calendar_today, "Date", displayDate),
                    _detailItem(Icons.people, "Pax", "$jumlahPenumpang Person"),
                  ],
                ),
              ],
            ),
          ),

          // FOOTER: TOTAL PRICE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: navyBlue,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Payment",
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  "Rp ${NumberFormat('#,###').format(totalHarga)}",
                  style: GoogleFonts.inter(
                    color: goldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: slateGrey),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: slateGrey),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value.length > 12 ? "${value.substring(0, 10)}..." : value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: navyBlue,
          ),
        ),
      ],
    );
  }
}
