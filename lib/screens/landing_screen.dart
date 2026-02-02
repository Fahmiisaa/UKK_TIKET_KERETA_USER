import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color navyBlue = const Color(0xFF0A192F);
    final Color goldAccent = const Color(0xFFC5A059);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: navyBlue,
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1474487548417-781cb71495f3?q=80&w=2000',
                ),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  navyBlue.withOpacity(0.8),
                  navyBlue,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  Text(
                    "EXECU",
                    style: GoogleFonts.cinzel(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: goldAccent,
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    "TRAIN",
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 8,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "Experience the Gold Standard of Rail Travel",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Booking exclusive executive train tickets has never been this seamless.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldAccent,
                        foregroundColor: navyBlue,
                        elevation: 5,
                        shadowColor: goldAccent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "START YOUR JOURNEY",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
