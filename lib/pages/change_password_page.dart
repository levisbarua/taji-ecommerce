import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text;
    final newPw = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      _showMessage('Please fill in all fields', isError: true);
      return;
    }
    if (newPw.length < 8 || !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(newPw)) {
      _showMessage('New password must be at least 8 characters with uppercase, lowercase, and a number', isError: true);
      return;
    }
    if (newPw != confirm) {
      _showMessage('New passwords do not match', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await SupabaseService.client.auth.updateUser(UserAttributes(password: newPw));
      if (!mounted) return;
      _showMessage('Password changed successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to change password. Check your current password.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = SupabaseService.client.auth.currentUser?.email;
    if (email == null) {
      _showMessage('No email on file', isError: true);
      return;
    }
    try {
      await SupabaseService.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      _showMessage('Password reset email sent to $email');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Failed to send reset email', isError: true);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? tajiError : tajiSuccess),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tajiDarkBg,
      appBar: AppBar(
        backgroundColor: tajiDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tajiTextLight),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Change password",
          style: TextStyle(color: tajiTextLight, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildPasswordField("Current password*", _currentPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("New password*", _newPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("Confirm new password*", _confirmPasswordController),
            const SizedBox(height: 16),
            Text(
              "Password must have at least 8 characters with uppercase, lowercase, and a number",
              style: TextStyle(color: tajiTextLight.withValues(alpha: 0.5), fontSize: 13),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: tajiTextLight))
                    : const Text("Change", style: TextStyle(color: tajiTextLight, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(color: const Color(0xFF1A1F24), borderRadius: BorderRadius.circular(8)),
              child: TextButton(
                onPressed: _forgotPassword,
                child: const Text("Forgot your password?", style: TextStyle(color: Color(0xFF22C55E), fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: tajiTextLight),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: tajiTextLight.withValues(alpha: 0.4), fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tajiTextLight.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF22C55E)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
