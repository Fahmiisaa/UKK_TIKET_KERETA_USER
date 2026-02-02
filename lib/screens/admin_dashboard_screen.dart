import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../widgets/loading_indicator.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadTrains();
      context.read<DataProvider>().loadSchedules();
      context.read<DataProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dataProvider = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Control',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF001F3F),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        foregroundColor: const Color(0xFF001F3F),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF001F3F), width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF001F3F)),
              onPressed: () async {
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child:
            dataProvider.isLoading
                ? const LoadingIndicator(message: 'Loading admin data...')
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium Welcome Section
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF001F3F).withOpacity(0.8),
                                const Color(0xFF001F3F).withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF001F3F).withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF001F3F).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
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
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Administrator',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          authProvider.user?.name ?? 'Admin',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Manage ExecuTrain Operations',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // System Analytics Section
                        Text(
                          'System Analytics',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF001F3F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monitor premium travel operations',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: const Color(0xFF001F3F),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Premium Statistics Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildLuxuryStatCard(
                                title: 'Total Trains',
                                value: dataProvider.trains.length.toString(),
                                icon: Icons.train,
                                color: const Color(0xFF001F3F),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildLuxuryStatCard(
                                title: 'Active Schedules',
                                value: dataProvider.schedules.length.toString(),
                                icon: Icons.schedule,
                                color: const Color(0xFF001F3F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLuxuryStatCard(
                                title: 'Premium Customers',
                                value: dataProvider.customers.length.toString(),
                                icon: Icons.people,
                                color: const Color(0xFF001F3F),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildLuxuryStatCard(
                                title: 'Total Bookings',
                                value: dataProvider.bookings.length.toString(),
                                icon: Icons.book_online,
                                color: const Color(0xFF001F3F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Management Tools Section
                        Text(
                          'Management Tools',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF001F3F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Control and optimize ExecuTrain services',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: const Color(0xFF001F3F),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Premium Menu Cards
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildLuxuryMenuCard(
                                icon: Icons.train,
                                title: 'Train Management',
                                subtitle: 'Add, edit, remove trains',
                                color: const Color(0xFF001F3F),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Train management features coming soon',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      backgroundColor: const Color(0xFF001F3F),
                                    ),
                                  );
                                },
                              ),
                              _buildLuxuryMenuCard(
                                icon: Icons.schedule,
                                title: 'Schedule Control',
                                subtitle: 'Manage departure schedules',
                                color: const Color(0xFF001F3F),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Schedule management features coming soon',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      backgroundColor: const Color(0xFF001F3F),
                                    ),
                                  );
                                },
                              ),
                              _buildLuxuryMenuCard(
                                icon: Icons.people,
                                title: 'Customer Care',
                                subtitle: 'View and manage customers',
                                color: const Color(0xFF001F3F),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Customer management features coming soon',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      backgroundColor: const Color(0xFF001F3F),
                                    ),
                                  );
                                },
                              ),
                              _buildLuxuryMenuCard(
                                icon: Icons.bar_chart,
                                title: 'Analytics',
                                subtitle: 'Reports and statistics',
                                color: const Color(0xFF001F3F),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Analytics features coming soon',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      backgroundColor: const Color(0xFF001F3F),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Error message with luxury styling
                        if (dataProvider.error != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              dataProvider.error!,
                              style: GoogleFonts.montserrat(
                                color: Colors.red.shade200,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildLuxuryStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1A1A), const Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuxuryMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1A1A), const Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
