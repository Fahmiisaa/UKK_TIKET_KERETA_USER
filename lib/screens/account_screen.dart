import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart'; // Pastikan import login_screen tersedia

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  final Color navyBlue = const Color(0xFF001F3F);
  final Color goldColor = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: navyBlue,
        centerTitle: true,
        // TOMBOL KEMBALI WARNA GOLD ACCENT
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: goldColor, // Perubahan warna di sini
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'MY PROFILE',
          style: GoogleFonts.cinzel(
            color: goldColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profil
            _buildProfileHeader(
              user?.name ?? 'User 01',
              user?.email ?? 'user01@executrain.com',
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Account Security'),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    Icons.person_outline,
                    'Edit Profile',
                    'Update your personal data',
                  ),
                  _buildMenuTile(
                    Icons.lock_outline,
                    'Change Password',
                    'Keep your account secure',
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle('Payment System'),
                  const SizedBox(height: 12),
                  _buildPaymentCard(
                    'Visa Platinum',
                    '**** **** **** 7782',
                    '09/27',
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    Icons.add_card_rounded,
                    'Add New Method',
                    'Link a new credit card or e-wallet',
                  ),
                  _buildMenuTile(
                    Icons.receipt_long_outlined,
                    'Transaction History',
                    'View all your previous payments',
                  ),

                  const SizedBox(height: 40),

                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'SIGN OUT',
                        style: GoogleFonts.montserrat(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: goldColor.withOpacity(0.2),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: goldColor,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            email,
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: navyBlue,
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: navyBlue),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black45),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildPaymentCard(String brand, String number, String expiry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [navyBlue, const Color(0xFF003366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: navyBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                brand,
                style: GoogleFonts.montserrat(
                  color: goldColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.contactless_outlined, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            number,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRY',
                    style: TextStyle(color: Colors.white54, fontSize: 9),
                  ),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.credit_card, color: Colors.white24, size: 40),
            ],
          ),
        ],
      ),
    );
  }
}
