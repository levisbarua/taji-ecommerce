import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';
import '../services/user_session.dart';
import '../services/managers.dart';
import 'shop_page.dart';

final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showFields = false;
  bool _obscurePassword = true;
  bool _isLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _showPolicyDialog(String title, String content) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tajiDarkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: tajiTextLight, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(color: tajiTextLight.withValues(alpha: 0.8), fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const SizedBox(height: 20),

                if (!_showFields) ...[
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: pureYellow,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/taji.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => const Center(child: Text("TAJI", style: TextStyle(color: pureBlack, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Welcome to Taji",
                          style: TextStyle(
                            color: tajiTextLight,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Elevate your space with curated art and design",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: pureWhite.withValues(alpha: 0.7),
                            fontSize: 18,
                            
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 350),

                  _buildSimplifiedSocialButton(
                    "Continue with Google",
                    Image.asset('assets/images/google_logo.png', width: 24, height: 24),
                    pureWhite,
                    pureBlack,
                    () => _handleSocialAuth(_isLogin ? 'Google Login' : 'Google Signup'),
                  ),
                  const SizedBox(height: 16),
                  _buildSimplifiedSocialButton(
                    "Continue with Facebook",
                    const Icon(Icons.facebook, color: tajiTextLight, size: 28),
                    const Color(0xFF1877F2),
                    tajiTextLight,
                    () => _handleSocialAuth(_isLogin ? 'Facebook Login' : 'Facebook Signup'),
                  ),
                  const SizedBox(height: 16),

                  _buildSimplifiedSocialButton(
                    _isLogin ? "Log in with email or phone" : "Create an account with email or phone",
                    null,
                    pureYellow,
                    pureBlack,
                    () => setState(() => _showFields = true),
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: pureWhite, fontSize: 16),
                        children: [
                          TextSpan(text: _isLogin ? "Don't have an account? " : "Already registered? "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _toggleMode,
                              child: Text(
                                _isLogin ? "Create one now" : "Log in",
                                style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _showFields = false),
                        icon: const Icon(Icons.arrow_back, color: pureWhite),
                      ),
                      Text(
                        _isLogin ? "Log in" : "Create an account",
                        style: const TextStyle(color: pureWhite, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  if (!_isLogin) ...[
                    _buildSimplifiedSocialButton(
                      "Continue with Google",
                      Image.asset('assets/images/google_logo.png', width: 20, height: 20),
                      pureWhite,
                      pureBlack,
                      () => _handleSocialAuth('Google Signup'),
                    ),
                    const SizedBox(height: 12),
                    _buildSimplifiedSocialButton(
                      "Continue with Facebook",
                      const Icon(Icons.facebook, color: tajiTextLight, size: 24),
                      const Color(0xFF1877F2),
                      tajiTextLight,
                      () => _handleSocialAuth('Facebook Signup'),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_isLogin) ...[
                    _buildRefinedOutlinedField(
                      label: 'Email address*',
                      pureWhite: pureWhite,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'Password*',
                      isPassword: true,
                      obscure: _obscurePassword,
                      pureWhite: pureWhite,
                      controller: _passwordController,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ] else ...[
                    _buildRefinedOutlinedField(
                      label: 'Email address*',
                      pureWhite: pureWhite,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'Password*',
                      isPassword: true,
                      obscure: _obscurePassword,
                      pureWhite: pureWhite,
                      controller: _passwordController,
                      helperText: "Avoid disclosing your password to anyone",
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'First name*',
                      pureWhite: pureWhite,
                      controller: _firstNameController,
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'Last name*',
                      pureWhite: pureWhite,
                      controller: _lastNameController,
                    ),
                    const SizedBox(height: 16),
                    _buildRefinedOutlinedField(
                      label: 'Phone number*',
                      pureWhite: pureWhite,
                      controller: _phoneController,
                      showClearIcon: true,
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handlePrimaryAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pureYellow,
                        foregroundColor: pureBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isLogin ? "Log in" : "Create an account",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 60),
                
                Center(
                  child: Text(
                    "By continuing you agree to the",
                    style: TextStyle(color: pureWhite.withValues(alpha: 0.5), fontSize: 16),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showPolicyDialog(
                          "Terms and Conditions",
                          "Welcome to Taji. By using our service, you agree to these terms... [Placeholder for full Terms content]",
                        ),
                        child: Text(
                          "Terms and Conditions",
                          style: TextStyle(
                            color: pureWhite.withValues(alpha: 0.7),
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(" and ", style: TextStyle(color: pureWhite.withValues(alpha: 0.5), fontSize: 16)),
                      GestureDetector(
                        onTap: () => _showPolicyDialog(
                          "Privacy Policy",
                          "Your privacy is important to us. This policy explains how we collect and use your data... [Placeholder for full Privacy content]",
                        ),
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            color: pureWhite.withValues(alpha: 0.7),
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrimaryAuth() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      _showErrorSnackBar('Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      _showErrorSnackBar('Please enter your password');
      return;
    }
    if (!_passwordRegex.hasMatch(password)) {
      _showErrorSnackBar('Password must be at least 8 characters with uppercase, lowercase, and a number');
      return;
    }

    if (!_isLogin) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();

      if (firstName.isEmpty || lastName.isEmpty) {
        _showErrorSnackBar('Please enter your full name');
        return;
      }
      if (phone.isEmpty) {
        _showErrorSnackBar('Please enter your phone number');
        return;
      }
    }

    if (!context.mounted) return;

    try {
      if (_isLogin) {
        await SupabaseService.signIn(email: email, password: password);
      } else {
        final firstName = _firstNameController.text.trim();
        final lastName = _lastNameController.text.trim();
        final phone = _phoneController.text.trim();
        await SupabaseService.signUp(
          email: email,
          password: password,
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'phone': phone,
            'name': '$firstName $lastName',
          },
        );
        await ProfileManager.saveSignupData(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar('Authentication failed. Please check your credentials and try again.');
      }
      return;
    }

    if (!context.mounted) return;

    final supabaseUser = UserSession.currentSupabaseUser;
    if (supabaseUser != null && supabaseUser.email != null && supabaseUser.id.isNotEmpty) {
      await UserSession.saveSession(supabaseUser.email!, supabaseUser.id);
    } else {
      return;
    }

    final isAdmin = await UserSession.isAdminAsync(supabaseUser.id);

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ShopPage(isAdmin: isAdmin)),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Calibri')),
        backgroundColor: pureYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSocialAuth(String method) async {
    try {
      final isGoogle = method.toLowerCase().contains('google');

      if (isGoogle) {
        await SupabaseService.signInWithGoogle();
      } else {
        await SupabaseService.signInWithFacebook();
      }

      if (!mounted) return;

      final user = UserSession.currentSupabaseUser;
      if (user != null && user.email != null) {
        await UserSession.saveSession(user.email!, user.id);
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ShopPage(isAdmin: false)),
        (route) => false,
      );
    } catch (_) {
      if (mounted) {
        _showErrorSnackBar('Authentication failed. Please try again.');
      }
    }
  }


  Widget _buildSimplifiedSocialButton(String label, Widget? icon, Color bgColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefinedOutlinedField({
    required String label,
    required Color pureWhite,
    bool isPassword = false,
    bool obscure = false,
    String? helperText,
    bool showClearIcon = false,
    VoidCallback? onToggleVisibility,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(primaryColor: pureYellow),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: tajiTextLight, fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: tajiTextLight.withValues(alpha: 0.5), fontSize: 14),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: tajiTextLight.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: pureYellow, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: onToggleVisibility,
                      icon: Icon(
                        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: tajiTextLight.withValues(alpha: 0.3),
                        size: 20,
                      ),
                    )
                  : (showClearIcon
                      ? IconButton(
                          onPressed: () => controller?.clear(),
                          icon: Icon(Icons.cancel, color: tajiTextLight.withValues(alpha: 0.3), size: 20),
                        )
                      : null),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: TextStyle(color: tajiTextLight.withValues(alpha: 0.4), fontSize: 12),
          ),
        ],
      ],
    );
  }
}
