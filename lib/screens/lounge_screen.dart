import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoungeScreen extends StatelessWidget {
  const LoungeScreen({super.key});

  final Color navyBlue = const Color(0xFF001F3F);
  final Color goldColor = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: navyBlue,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFFD4AF37),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ELITE LOUNGE',
          style: GoogleFonts.cinzel(
            color: goldColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image / Header
            _buildLoungeHero(),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Platinum Privileges',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nikmati kenyamanan eksklusif sebelum keberangkatan Anda.',
                    style: GoogleFonts.montserrat(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // List Fasilitas
                  _buildFacilityItem(
                    Icons.wifi_rounded,
                    'High-Speed Connectivity',
                    'Akses internet ultra-cepat untuk produktivitas Anda.',
                  ),
                  _buildFacilityItem(
                    Icons.coffee_maker_rounded,
                    'Premium Refreshments',
                    'Pilihan kopi gourmet dan hidangan penutup artisan.',
                  ),
                  _buildFacilityItem(
                    Icons.weekend_rounded,
                    'Private Suites',
                    'Area istirahat pribadi yang tenang dan nyaman.',
                  ),
                  _buildFacilityItem(
                    Icons.shower_rounded,
                    'Shower Facilities',
                    'Segarkan diri Anda dengan fasilitas mandi premium.',
                  ),

                  const SizedBox(height: 40),

                  // Lokasi Lounge Card
                  _buildLocationCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoungeHero() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: navyBlue,
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1563911302283-d2bc129e7570?q=80&w=1000',
          ), // Gambar Lounge Mewah
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color(0xFFF8F9FA).withOpacity(1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars_rounded, color: goldColor, size: 50),
              const SizedBox(height: 10),
              Text(
                'Platinum Member Only',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: goldColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: navyBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Colors.white70,
            size: 30,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lounge Location',
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                'Platform 1, Executive Wing',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text('Map', style: TextStyle(color: goldColor)),
          ),
        ],
      ),
    );
  }
}
