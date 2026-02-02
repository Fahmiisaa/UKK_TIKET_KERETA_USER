import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<DataProvider>().transactions;
    final navyBlue = const Color(0xFF0A192F);
    final goldAccent = const Color(0xFFC5A059);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: navyBlue,
        centerTitle: true,
        // Menambahkan IconButton dengan warna goldAccent
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: goldAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "TRANSACTION HISTORY",
          style: GoogleFonts.cinzel(
            color: goldAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          transactions.isEmpty
              ? _buildEmptyState(goldAccent)
              : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final trx = transactions[index];
                  return _buildTransactionCard(trx, navyBlue, goldAccent);
                },
              ),
    );
  }

  Widget _buildEmptyState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: color.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No transactions found",
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(trx, navyBlue, goldAccent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trx.id,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(trx.createdAt),
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rp ${trx.amount.toStringAsFixed(0)}",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A56BE),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "PAID",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
