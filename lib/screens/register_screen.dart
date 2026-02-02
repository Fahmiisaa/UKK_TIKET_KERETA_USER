import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan ini untuk FilteringTextInputFormatter
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        _nameController.text.trim(),
        _usernameController.text.trim(),
        _nikController.text.trim(),
        _phoneController.text.trim(),
        _addressController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registrasi Berhasil! Silakan Login.',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.train,
                        size: 60,
                        color: Color(0xFF001F3F),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Create Account',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF001F3F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _inputField(
                  _nameController,
                  'Nama Lengkap',
                  Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _inputField(
                  _usernameController,
                  'Username',
                  Icons.alternate_email,
                ),
                const SizedBox(height: 16),
                _inputField(
                  _nikController,
                  'NIK',
                  Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  // Membatasi hanya input angka
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'NIK wajib diisi';
                    if (v.length != 16) return 'NIK harus 16 angka';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _inputField(
                  _phoneController,
                  'No. Telepon',
                  Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _inputField(
                  _addressController,
                  'Alamat',
                  Icons.home_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _inputField(
                  _passwordController,
                  'Password',
                  Icons.lock_outline,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _inputField(
                  _confirmPasswordController,
                  'Konfirmasi Password',
                  Icons.lock_reset,
                  isPassword: true,
                  isConfirm: true,
                ),

                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001F3F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        authProvider.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'DAFTAR SEKARANG',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: TextSpan(
                      text: "Sudah punya akun? ",
                      style: GoogleFonts.montserrat(color: Colors.black54),
                      children: const [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: Color(0xFF001F3F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isConfirm = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: GoogleFonts.montserrat(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        counterText: "", // Menyembunyikan counter angka di bawah input
        labelStyle: const TextStyle(color: Color(0xFF001F3F)),
        prefixIcon: Icon(icon, color: const Color(0xFF001F3F)),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                )
                : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator:
          validator ??
          (v) {
            if (v == null || v.isEmpty) return 'Wajib diisi';
            if (isConfirm && v != _passwordController.text)
              return 'Password tidak cocok';
            return null;
          },
    );
  }
}
