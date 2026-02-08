import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';

class ManageCoachScreen extends StatefulWidget {
  const ManageCoachScreen({super.key});

  @override
  State<ManageCoachScreen> createState() => _ManageCoachScreenState();
}

class _ManageCoachScreenState extends State<ManageCoachScreen> {
  // --- Color Palette ---
  final Color navyPrimary = const Color(0xFF0A192F);
  final Color navyLight = const Color(0xFF172A45);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color bgLight = const Color(0xFFF5F7FA);
  final Color redError = const Color(0xFFEF4444);
  final Color textGrey = const Color(0xFF64748B);

  String? selectedTrainId;
  String? selectedTrainName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().getKereta();
    });
  }

  // --- Logic Delete Dummy ---
  void _confirmDelete(String coachName) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Hapus Gerbong?"),
            content: Text("Anda akan menghapus '$coachName' dari rangkaian."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
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
          'Coach Configuration',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- TOP SECTION: TRAIN SELECTOR ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: BoxDecoration(
              color: navyPrimary,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: navyPrimary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Train Fleet",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTrainDropdown(adminProvider),
              ],
            ),
          ),

          // --- BODY: COACH LIST ---
          Expanded(
            child:
                selectedTrainId == null
                    ? _buildEmptyState()
                    : _buildCoachList(adminProvider),
          ),
        ],
      ),

      // Floating Action Button hanya muncul jika kereta dipilih
      floatingActionButton:
          selectedTrainId != null
              ? FloatingActionButton.extended(
                onPressed: () => _showCoachFormSheet(context),
                backgroundColor: navyPrimary,
                icon: Icon(Icons.add_link_rounded, color: goldAccent),
                label: Text(
                  'Add Coach',
                  style: GoogleFonts.plusJakartaSans(
                    color: goldAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildTrainDropdown(AdminProvider data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTrainId,
          hint: Text(
            "Choose a train to configure...",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          isExpanded: true,
          dropdownColor: navyLight,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
          ),
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          items:
              data.listKereta.map((train) {
                return DropdownMenuItem<String>(
                  value: train['id'].toString(),
                  child: Text(train['nama_kereta'] ?? 'Unknown Train'),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedTrainId = value;
              // Cari nama kereta untuk keperluan display (opsional)
              final train = data.listKereta.firstWhere(
                (element) => element['id'].toString() == value,
              );
              selectedTrainName = train['nama_kereta'];

              // Trigger fetch data gerbong by ID Kereta
              // context.read<AdminProvider>().getGerbongByKereta(value!);
            });
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.train_outlined,
              size: 60,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Train Selected",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: navyPrimary,
            ),
          ),
          Text(
            "Please select a fleet from the top menu",
            style: GoogleFonts.plusJakartaSans(color: textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachList(AdminProvider data) {
    // Dummy Data (Ganti dengan data dari Provider: data.listGerbong)
    final List<Map<String, dynamic>> coaches = [
      {'nama': 'Eksekutif 1', 'kapasitas': 50, 'tipe': 'PASSENGER'},
      {'nama': 'Eksekutif 2', 'kapasitas': 50, 'tipe': 'PASSENGER'},
      {'nama': 'Kereta Makan (M)', 'kapasitas': 24, 'tipe': 'DINING'},
      {'nama': 'Eksekutif 3', 'kapasitas': 50, 'tipe': 'PASSENGER'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 80),
      itemCount: coaches.length,
      itemBuilder: (context, index) {
        return _buildCoachCard(coaches[index], index);
      },
    );
  }

  Widget _buildCoachCard(Map<String, dynamic> coach, int index) {
    final String nama = coach['nama'];
    final int kapasitas = coach['kapasitas'];
    // Deteksi tipe otomatis berdasarkan nama jika API tidak menyediakan tipe
    final bool isSpecial =
        nama.toLowerCase().contains('makan') ||
        nama.toLowerCase().contains('pembangkit');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: navyPrimary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                isSpecial
                    ? Colors.orange.withOpacity(0.1)
                    : navyPrimary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isSpecial ? Icons.restaurant_rounded : Icons.chair_alt_rounded,
            color: isSpecial ? Colors.orange : navyPrimary,
            size: 24,
          ),
        ),
        title: Text(
          nama,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: navyPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.people_outline_rounded, size: 14, color: textGrey),
            const SizedBox(width: 4),
            Text(
              "$kapasitas Seats",
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textGrey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 20, color: textGrey),
              onPressed:
                  () => _showCoachFormSheet(context, existingData: coach),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: redError.withOpacity(0.8),
              ),
              onPressed: () => _confirmDelete(nama),
            ),
          ],
        ),
      ),
    );
  }

  // --- FORM SHEET (ADD / EDIT) ---
  void _showCoachFormSheet(
    BuildContext context, {
    Map<String, dynamic>? existingData,
  }) {
    final bool isEdit = existingData != null;
    final nameController = TextEditingController(
      text: isEdit ? existingData['nama'] : '',
    );
    final capController = TextEditingController(
      text: isEdit ? existingData['kapasitas'].toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Icon(Icons.chair_rounded, color: navyPrimary),
                    const SizedBox(width: 12),
                    Text(
                      isEdit ? 'Edit Coach' : 'Add New Coach',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: navyPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  nameController,
                  "Coach Name (e.g., Eksekutif 1)",
                ),
                const SizedBox(height: 16),
                _buildTextField(capController, "Seat Capacity", isNumber: true),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Logika simpan
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Save Configuration',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.plusJakartaSans(
        color: navyPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: bgLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: navyPrimary),
        ),
      ),
    );
  }
}
