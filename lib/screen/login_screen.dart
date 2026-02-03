import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dineall/screen/homepage.dart';
import 'package:dineall/screen/sign_up.dart';
import 'package:dineall/service/user_service.dart';
// import 'package:dineall/screen/reset_password.dart';

import '../services/auth_api.dart';
import '../services/token_store.dart';
import '../services/token_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ✅ Controllers
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // ✅ UI state (unchanged)
  bool _obscure = true;
  bool _rememberMe = false;

  // ✅ Validation state (unchanged)
  String? _emailError;
  String? _passwordError;

  // ✅ Services (NEW - no UI change)
  final AuthApi _authApi = AuthApi();
  final TokenStore _tokenStore = TokenStore();
  late TokenManager _tokenManager;

  // Colors from the HTML/Tailwind config (unchanged)
  static const Color primary = Color(0xFF8A0000);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color brandBrown = Color(0xFF3E2723);
  // static const Color brandRedLight = Color(0xFFE32929);

  @override
  void initState() {
    super.initState();

    // default: no credential persistence (more secure)
    _tokenManager = TokenManager(
      authApi: _authApi,
      tokenStore: _tokenStore,
      renewBefore: const Duration(minutes: 5),
      persistCredentials: false,
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    setState(() {
      _emailError = email.isEmpty ? 'Email is required' : null;
      _passwordError = password.isEmpty ? 'Password is required' : null;
    });

    if (_emailError != null || _passwordError != null) return;

    try {
      // ✅ لو Remember Me = true هنفعّل persistCredentials عشان الـ token يتجدد حتى بعد restart
      _tokenManager = TokenManager(
        authApi: _authApi,
        tokenStore: _tokenStore,
        renewBefore: const Duration(minutes: 5),
        persistCredentials: _rememberMe,
      );

      // ✅ Auth API call (Hidden - no UI change)
      const branchName = 'Act';
      final token = await _authApi.authenticate(
        userName: email, // API expects userName
        password: password,
        branchName: branchName,
      );

      // ✅ store credentials in session (and optionally secure storage if rememberMe=true)
      await _tokenManager.setSessionCredentials(
        userName: email,
        password: password,
        branchName: branchName,
      );

      // ✅ store token securely
      await _tokenManager.saveInitialTokenFromLogin(token);

      // ✅ debug prints (token + json) — مفيش UI تغيير
      // ignore: avoid_print
      print('✅ ACCESS TOKEN: ${token.accessToken}');
      // ignore: avoid_print
      print('✅ TOKEN TYPE: ${token.tokenType}');
      // ignore: avoid_print
      print('✅ EXPIRES AT: ${token.expiresAt.toIso8601String()}');
      // ignore: avoid_print
      print('✅ FULL JSON: ${token.rawJson}');

      // ✅ keep your existing logic (unchanged)
      UserService().login(email);

      // ✅ navigation (same as you had)
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Homepage(),
        ),
      );
    } catch (e) {
      // Hidden: console only (no UI changes)
      // ignore: avoid_print
      print('❌ LOGIN ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeText = GoogleFonts.plusJakartaSans();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with background image + overlay + logo/title
              SizedBox(
                height: size.height * 0.30,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAFAxW8YFxBEWieVn0TYfXZRWiiyDw9yN7l7TWhdqKujdMEgzgRb06CniX4J4S3LidFIqjI5YDkXGqx9msKqhtSjemLoXPBAae4N_kovOp2e5R8X7S4hf_Ym5du5WGOKSc_A_dNDPIPohy2Mte5BX5P6hblTwgsKkXpGZJzQldjDL8DihgKHeXD7Jnu_nwwyDcSE6fBcrrAgXvNvGYgUsyTSL1l4ueQTqOkD2eVRHvm9JapGHmAakXLmgQZzY3tq5KLG4staOwR0cU',
                              fit: BoxFit.cover,
                            ),
                            Container(color: Colors.black.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
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
                            style: themeText.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'One App, Endless Eats & Drinks',
                            style: themeText.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title / subtitle
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Welcome',
                                style: themeText.copyWith(
                                  color: brandBrown,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please sign in to your account',
                                style: themeText.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        Text(
                          'Email',
                          style: themeText.copyWith(
                            color: brandBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            errorText: _emailError,
                            prefixIcon: Icon(Icons.mail, color: Colors.grey[500]),
                            filled: true,
                            fillColor: backgroundLight.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: Color(0xFFEACDCD)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: Color(0xFFEACDCD)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: primary, width: 1.5),
                            ),
                          ),
                          style: themeText.copyWith(color: brandBrown),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        Text(
                          'Password',
                          style: themeText.copyWith(
                            color: brandBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            errorText: _passwordError,
                            prefixIcon: Icon(Icons.lock, color: Colors.grey[500]),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[500],
                              ),
                            ),
                            filled: true,
                            fillColor: backgroundLight.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: Color(0xFFEACDCD)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: Color(0xFFEACDCD)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: primary, width: 1.5),
                            ),
                          ),
                          style: themeText.copyWith(color: brandBrown),
                        ),
                        const SizedBox(height: 8),

                        // Remember + Forgot
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (v) => setState(() => _rememberMe = v ?? false),
                              activeColor: primary,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              'Remember Me',
                              style: themeText.copyWith(
                                color: Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            /*
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ResetPasswordScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: themeText.copyWith(
                                  color: brandRedLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            */
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Sign In
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _handleLogin, // ✅ only changed logic
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 8,
                              shadowColor: primary.withOpacity(0.2),
                            ),
                            child: Text(
                              'Sign In',
                              style: themeText.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Divider "OR CONTINUE WITH"
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: themeText.copyWith(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Social buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: const StadiumBorder(),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.network(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA6jzeNaDfC3MwFO4odKoxR0i7kd1sqbJPWrydf569WsZK1cXyIncdPiDpN_fA9XiVtjkjJwb_mavTFsnnRZMTwy-QqpBUQ2zCbgpmgW7zW2DSndA9RIsYVjSUMhY9mbi-j4xr6uKHMo_1869-ndUNw8CugfarqWokRZltvIBvWeENyIQcnU-QyAKZUmnFHEA-2SAtue8y8V37eBX9udYJ86O6bP_f85n0KSQe3Eow8gw5pnNsRhtKJakpUVHxbkxvW4wxDdb4mYjQ',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Google',
                                      style: themeText.copyWith(
                                        color: brandBrown,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: const StadiumBorder(),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.apple, color: brandBrown, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Apple',
                                      style: themeText.copyWith(
                                        color: brandBrown,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom text
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: themeText.copyWith(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: themeText.copyWith(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
