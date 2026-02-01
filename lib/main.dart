import 'package:flutter/material.dart';
import 'package:dineall/screen/login_screen.dart';
import 'package:dineall/screen/chatbot_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const DineAllApp());
}

class DineAllApp extends StatelessWidget {
  const DineAllApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DineAll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B0000)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        ChatbotScreen.routeName: (context) => const ChatbotScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to Login Screen after animation + delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // Colors from Tailwind config
    const primary = Color(0xFF8B0000); // --dark-red
    const brandWhite = Colors.white;

    return Scaffold(
      backgroundColor: primary,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Blurs
          // Top Right Blur (Glow)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.05),
                    blurRadius: 120,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Left Blur: black/20, blur 100px
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 48), // Top spacer

                // Center Section: Logo + Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with Circle
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circle Border (scaled)
                          Transform.scale(
                            scale: 1.5,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                          // Icon
                          Image.asset(
                            'assets/images/logo.png',
                            width: 128,
                            height: 128,
                            color: brandWhite,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8), // mt-2
                    // Title
                    Text(
                      'DineAll',
                      style: GoogleFonts.plusJakartaSans(
                        color: brandWhite,
                        fontSize: 56,
                        fontWeight: FontWeight.w800, // ExtraBold
                        letterSpacing: -1.5, // tracking-tight
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16), // mb-4
                    // Subtitle
                    Text(
                      'One App, Endless Eats & Drinks.',
                      style: TextStyle(
                        color: brandWhite.withValues(alpha: 0.9),
                        fontSize: 18, // text-lg
                        fontWeight: FontWeight.w500, // font-medium
                        letterSpacing: 0.5, // tracking-wide
                      ),
                    ),
                  ],
                ),

                // Bottom Section: Removed Progress + Footer Text
                const SizedBox(height: 80), // Keep some spacing if needed or remove entirely
              ],
            ),
          ),
        ],
      ),
    );
  }
}
