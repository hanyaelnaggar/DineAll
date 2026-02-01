import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  // Brand colors
  static const Color brandRed = Color(0xFF8A0000);
  static const Color brandRedHover = Color(0xFF700000);
  static const Color brandBrown = Color(0xFF3E2723);
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color backgroundDark = Color(0xFF1C1C1E);
  static const Color brandBorder = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAFAxW8YFxBEWieVn0TYfXZRWiiyDw9yN7l7TWhdqKujdMEgzgRb06CniX4J4S3LidFIqjI5YDkXGqx9msKqhtSjemLoXPBAae4N_kovOp2e5R8X7S4hf_Ym5du5WGOKSc_A_dNDPIPohy2Mte5BX5P6hblTwgsKkXpGZJzQldjDL8DihgKHeXD7Jnu_nwwyDcSE6fBcrrAgXvNvGYgUsyTSL1l4ueQTqOkD2eVRHvm9JapGHmAakXLmgQZzY3tq5KLG4staOwR0cU',
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black.withOpacity(0.6)),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/logo.png',
                                  width: 48,
                                  height: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'DineAll',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Reset Password',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Card
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: brandRed.withOpacity(0.1),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 30,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Enter your email address and we will send you a link to reset your password.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email field
                              Text(
                                'EMAIL ADDRESS',
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark ? Colors.grey[300] : brandBrown,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark ? Colors.white : brandBrown,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'example@email.com',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w600,
                                  ),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  prefixIcon: Icon(Icons.mail, color: Colors.grey[400]),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(999),
                                    borderSide: BorderSide(
                                      color: isDark ? const Color(0xFF3F3F46) : brandBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(999),
                                    borderSide: const BorderSide(color: brandRed, width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Button
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: trigger password reset
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandRed,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    elevation: 8,
                                    shadowColor: brandRed.withOpacity(0.2),
                                  ).copyWith(
                                    overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                                      if (states.contains(MaterialState.pressed)) return brandRedHover;
                                      return null;
                                    }),
                                  ),
                                  child: Text(
                                    'Send Reset Link',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Divider
                              Divider(color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0), height: 32, thickness: 1),

                              // Back to Login
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.arrow_back, color: brandRed, size: 18),
                                label: Text(
                                  'Back to Login',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: brandRed,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Having trouble? ',
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: navigate to support
                            },
                            child: Text(
                              'Contact Support',
                              style: GoogleFonts.plusJakartaSans(
                                color: brandRed,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
