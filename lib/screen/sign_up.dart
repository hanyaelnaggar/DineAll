import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dineall/screen/homepage.dart';
import 'package:dineall/screen/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  // Validation State
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Password Requirements State
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _hasSpecialCharacters = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final value = _passwordCtrl.text;
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasDigits = value.contains(RegExp(r'[0-9]'));
      // Broadened special character check to include - _ = + [ ] { } \ | ; : ' " , < . > / ? ~ `
      _hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+[\]\/\\`~;]'));
      
      // Clear the error message if user is typing, as we show the checklist now
      if (_passwordError != null) {
         _passwordError = null;
      }
    });
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must scroll to bottom and accept
      builder: (context) {
        final scrollController = ScrollController();
        bool reachedBottom = false;

        return StatefulBuilder(
          builder: (context, setState) {
            scrollController.addListener(() {
              if (!reachedBottom &&
                  scrollController.position.pixels >=
                      scrollController.position.maxScrollExtent - 50) {
                setState(() {
                  reachedBottom = true;
                });
              }
            });

            return AlertDialog(
              title: Text(
                'Terms & Conditions',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: const Color(0xFF3E2723),
                ),
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.maxFinite,
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Text(
                            '''
Welcome to DineAll!

1. **Acceptance of Terms**
   By creating an account and using our app, you agree to be bound by these Terms and Conditions.

2. **User Accounts**
   - You are responsible for maintaining the security of your account credentials.
   - You must provide accurate and complete information during registration.

3. **Ordering and Payments**
   - All orders are subject to availability.
   - Prices are subject to change without notice.
   - Payments are processed securely.

4. **Privacy Policy**
   - We value your privacy. Your data is collected and used in accordance with our Privacy Policy.
   - We do not sell your personal data to third parties.

5. **Code of Conduct**
   - You agree not to misuse the app or engage in fraudulent activities.
   - Respectful behavior towards delivery partners and restaurant staff is expected.

6. **Liability**
   - DineAll is not liable for any indirect or consequential damages arising from the use of the app.

7. **Termination**
   - We reserve the right to terminate or suspend your account for violating these terms.

8. **Changes to Terms**
   - We may update these terms from time to time. Continued use of the app implies acceptance of the new terms.

(Scroll to the bottom to accept)
                            ''',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!reachedBottom)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please read to the bottom to continue',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: reachedBottom
                      ? () {
                          Navigator.of(context).pop();
                          this.setState(() {
                            _agreedToTerms = true;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A0000),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'I Agree',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _passwordCtrl.removeListener(_updatePasswordStrength);
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors matching the design
    const primary = Color(0xFF8A0000);
    const accentRed = Color(0xFFE32929);
    const brandBrown = Color(0xFF3E2723);
    const backgroundLight = Color(0xFFF3F4F6);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header with Background Image
            SizedBox(
              height: size.height * 0.35,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAEoaAn14Dh6YjR01p4d0RIWy95zr_DVncf4BDHwVq5YKE09Sm3cYx0LOYsZjJP3YWMLfaph95iMv_z8G8lFNVxcWVjJApcp_hepg5x9EPNwQCk4y82DMUeqqv1Yq-ioLomKiRUDip0TgvrTPBTtTOq8_WYFV1GSN5vpzasvMM68BeVawQkjKmU7S5fnDzE9X3uIoVvfpk8469UcJTzjFrm56oFi1siOBNe8WnI1wSln0-VMe3BRYkiC1w7cf3GO-pI3rNwPG5LGUQ',
                    fit: BoxFit.cover,
                  ),
                  // Overlay
                  Container(color: Colors.black.withOpacity(0.5)),
                  
                  // Back Button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header Content (Logo + Title)
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 60,
                            height: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'DineAll',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create Account',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Form Card
            Transform.translate(
              offset: const Offset(0, -48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // First Name and Last Name
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('FIRST NAME'),
                                _buildTextField(
                                  hint: 'First Name',
                                  icon: Icons.person_outline,
                                  controller: _firstNameCtrl,
                                  errorText: _firstNameError,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('LAST NAME'),
                                _buildTextField(
                                  hint: 'Last Name',
                                  icon: Icons.person_outline,
                                  controller: _lastNameCtrl,
                                  errorText: _lastNameError,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email Address
                      _buildLabel('EMAIL ADDRESS'),
                      _buildTextField(
                        hint: 'Email address',
                        icon: Icons.mail_outline,
                        controller: _emailCtrl,
                        inputType: TextInputType.emailAddress,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      _buildLabel('PHONE NUMBER'),
                      _buildTextField(
                        hint: 'Phone Number',
                        icon: Icons.call_outlined,
                        controller: _phoneCtrl,
                        inputType: TextInputType.phone,
                        errorText: _phoneError,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildLabel('PASSWORD'),
                      TextField(
                        obscureText: _obscurePassword,
                        style: GoogleFonts.plusJakartaSans(
                          color: brandBrown,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          errorText: _passwordError,
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: brandBrown.withOpacity(0.3),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: brandBrown.withOpacity(0.4),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: brandBrown.withOpacity(0.4),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(color: primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Password Requirements Checklist
                      if (_passwordCtrl.text.isNotEmpty || _passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRequirementItem('At least 8 characters', _hasMinLength),
                              _buildRequirementItem('One uppercase letter', _hasUppercase),
                              _buildRequirementItem('One lowercase letter', _hasLowercase),
                              _buildRequirementItem('One number', _hasDigits),
                              _buildRequirementItem('One special character', _hasSpecialCharacters),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildLabel('CONFIRM PASSWORD'),
                      TextField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirmPassword,
                        style: GoogleFonts.plusJakartaSans(
                          color: brandBrown,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          errorText: _confirmPasswordError,
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: brandBrown.withOpacity(0.3),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: brandBrown.withOpacity(0.4),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: brandBrown.withOpacity(0.4),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(color: primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            final email = _emailCtrl.text.trim();
                            final password = _passwordCtrl.text.trim();
                            final confirmPassword = _confirmPasswordCtrl.text.trim();
                            final firstName = _firstNameCtrl.text.trim();
                            final lastName = _lastNameCtrl.text.trim();
                            final phone = _phoneCtrl.text.trim();

                            setState(() {
                              _firstNameError = firstName.isEmpty ? 'Required' : null;
                              _lastNameError = lastName.isEmpty ? 'Required' : null;
                              _emailError = email.isEmpty ? 'Required' : null;
                              _phoneError = phone.isEmpty ? 'Required' : null;
                              
                              // Check if password meets all requirements
                              bool isPasswordValid = _hasMinLength && 
                                                   _hasUppercase && 
                                                   _hasLowercase && 
                                                   _hasDigits && 
                                                   _hasSpecialCharacters;

                              _passwordError = isPasswordValid ? null : 'Please meet all password requirements';
                              
                              _confirmPasswordError = confirmPassword.isEmpty ? 'Required' : null;

                              if (_passwordError == null && password.isNotEmpty && confirmPassword.isNotEmpty && password != confirmPassword) {
                                _confirmPasswordError = 'Passwords do not match';
                              }
                            });

                            if (_firstNameError != null ||
                                _lastNameError != null ||
                                _emailError != null ||
                                _phoneError != null ||
                                _passwordError != null ||
                                _confirmPasswordError != null) {
                              return;
                            }

                            if (!_agreedToTerms) {
                              _showTermsDialog();
                              return;
                            }

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Homepage()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 8,
                            shadowColor: primary.withOpacity(0.2),
                          ),
                          child: Text(
                            'Create Account',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Terms Checkbox
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              activeColor: primary,
                              onChanged: (value) {
                                if (value == true) {
                                  _showTermsDialog();
                                } else {
                                  setState(() {
                                    _agreedToTerms = false;
                                  });
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showTermsDialog(),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.plusJakartaSans(
                                      color: brandBrown.withOpacity(0.5),
                                      fontSize: 11,
                                      height: 1.5,
                                    ),
                                    children: const [
                                      TextSpan(text: 'By signing up, you agree to our '),
                                      TextSpan(
                                        text: 'Terms',
                                        style: TextStyle(
                                          color: primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer Link
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.plusJakartaSans(
                                color: brandBrown,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.plusJakartaSans(
                                  color: accentRed,
                                  fontWeight: FontWeight.w800,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    const brandBrown = Color(0xFF3E2723);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: brandBrown,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? errorText,
  }) {
    const brandBrown = Color(0xFF3E2723);
    const primary = Color(0xFF8A0000);

    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: GoogleFonts.plusJakartaSans(
        color: brandBrown,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: brandBrown.withOpacity(0.3),
        ),
        prefixIcon: Icon(
          icon,
          color: brandBrown.withOpacity(0.4),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5).withValues(alpha: 0.5),
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
    );
  }

  Widget _buildRequirementItem(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: met ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
