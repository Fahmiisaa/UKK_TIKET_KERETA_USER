import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_provider.dart';

class ManageTrainScreen extends StatefulWidget {
  const ManageTrainScreen({super.key});

  @override
  State<ManageTrainScreen> createState() => _ManageTrainScreenState();
}

class _ManageTrainScreenState extends State<ManageTrainScreen> {
  // --- Color Palette (Konsisten dengan Schedule) ---
  final Color navyPrimary = const Color(0xFF0A192F);
  final Color goldAccent = const Color(0xFFC5A059);
  final Color bgLight = const Color(0xFFF5F7FA);
  final Color redError = const Color(0xFFEF4444);
  final Color textGrey = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().getKereta();
    });
  }

  void _confirmDelete(String id, String nama) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Hapus Armada?"),
            content: Text(
              "Anda akan menghapus kereta '$nama'. Data tidak dapat dikembalikan.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AdminProvider>().deleteKereta(id);
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
          'Fleet Management',
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
                onRefresh: () async => await adminProvider.getKereta(),
                color: navyPrimary,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: adminProvider.listKereta.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final train = adminProvider.listKereta[index];
                    return _buildModernTrainCard(train);
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTrainFormSheet(context),
        backgroundColor: navyPrimary,
        icon: Icon(Icons.add_rounded, color: goldAccent),
        label: Text(
          'Add Train',
          style: GoogleFonts.plusJakartaSans(
            color: goldAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildModernTrainCard(dynamic train) {
    final String nama = train['nama_kereta'] ?? 'Unknown';
    final String kelas = train['kelas'] ?? '-';
    final String kuota = train['kuota']?.toString() ?? '0';
    final String gerbong = train['jumlah_gerbong']?.toString() ?? '0';
    final String id = train['id']?.toString() ?? '0';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: navyPrimary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- HEADER CARD ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: navyPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.train_rounded,
                    color: navyPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Title & Class
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: navyPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: goldAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: goldAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          kelas.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB8860B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // --- INFO GRID ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              children: [
                _buildInfoItem(
                  Icons.airline_seat_recline_normal_rounded,
                  "$kuota Seats",
                  "Capacity",
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                _buildInfoItem(
                  Icons.view_column_rounded,
                  "$gerbong Cars",
                  "Configuration",
                ),
              ],
            ),
          ),

          // --- ACTION BUTTONS ---
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Trigger Edit (bisa buka modal dengan data terisi)
                      _showTrainFormSheet(context, existingData: train);
                    },
                    icon: Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: navyPrimary,
                    ),
                    label: Text(
                      "Edit Details",
                      style: TextStyle(color: navyPrimary),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _confirmDelete(id, nama),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: redError,
                    ),
                    label: Text("Remove", style: TextStyle(color: redError)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: textGrey),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: navyPrimary,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- FORM MODAL (Reusable untuk Add & Edit) ---
  void _showTrainFormSheet(
    BuildContext context, {
    Map<String, dynamic>? existingData,
  }) {
    final bool isEdit = existingData != null;

    // Initial Value jika Edit
    final nameController = TextEditingController(
      text: isEdit ? existingData['nama_kereta'] : '',
    );
    final descController = TextEditingController(
      text: isEdit ? existingData['deskripsi'] : '',
    ); // Asumsi ada field deskripsi
    final typeController = TextEditingController(
      text: isEdit ? existingData['kelas'] : '',
    );
    final coachController = TextEditingController(
      text: isEdit ? existingData['jumlah_gerbong']?.toString() : '',
    );
    final quotaController = TextEditingController(
      text: isEdit ? existingData['kuota']?.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header Form
                Row(
                  children: [
                    Icon(
                      isEdit
                          ? Icons.edit_note_rounded
                          : Icons.add_circle_outline_rounded,
                      color: navyPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdit ? 'Edit Train Data' : 'New Train Fleet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: navyPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scrollable Form Fields
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildInputLabel("Train Name"),
                      _buildTextField(nameController, "Ex: Argo Parahyangan"),

                      _buildInputLabel("Service Class"),
                      _buildTextField(typeController, "Ex: Executive"),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("Total Coaches"),
                                _buildTextField(
                                  coachController,
                                  "8",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("Seat Capacity"),
                                _buildTextField(
                                  quotaController,
                                  "400",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      _buildInputLabel("Description (Optional)"),
                      _buildTextField(
                        descController,
                        "Short description...",
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                // Submit Button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navyPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      // Tambahkan validasi & logika simpan/update ke Provider disini
                      if (nameController.text.isNotEmpty) {
                        Navigator.pop(context);
                        // Panggil provider...
                      }
                    },
                    child: Text(
                      isEdit ? 'Update Changes' : 'Save Train',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textGrey,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: navyPrimary),
        ),
      ),
    );
  }
}
