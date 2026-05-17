import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  final String title;
  final String? content;
  const InfoPage({super.key, required this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContent(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (content != null) {
      return Text(content!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 16, height: 1.6));
    }

    switch (title) {
      case "Privacy Policy":
        return _buildPrivacyPolicy(context);
      case "Help Center":
        return _buildHelpCenter(context);
      case "Terms of Service":
        return _buildTermsOfService(context);
      case "About Taji":
        return _buildAboutTaji(context);
      default:
        return Text("Information not found.", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)));
    }
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15, height: 1.6)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, "1. Data Collection", "We collect personal information that you provide to us, such as your name, email address, phone number, and shipping data when you create an account or make a purchase."),
        _buildSection(context, "2. Usage Data", "We automatically collect certain information when you visit the app, including IP address, device type, and app usage patterns to improve your experience."),
        _buildSection(context, "3. Data Security", "We implement industry-standard security measures to protect your personal data from unauthorized access, alteration, or disclosure."),
        _buildSection(context, "4. Your Rights", "You have the right to access, correct, or delete your personal data. You can request account deletion at any time via the Settings page."),
      ],
    );
  }

  Widget _buildHelpCenter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, "Track Your Order", "Go to 'My Orders' in your profile to see the real-time status of your purchases."),
        _buildSection(context, "Returns & Refunds", "We offer a 30-day return policy on all unworn items. Refunds are processed within 5-7 business days."),
        _buildSection(context, "Contact Support", "Need help? Email us at support@taji.com or use the 'Contact Support' button in your profile."),
        _buildSection(context, "Payment Methods", "We accept major credit cards, M-Pesa, and digital wallets for all transactions."),
      ],
    );
  }

  Widget _buildTermsOfService(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, "1. Acceptance of Terms", "By accessing or using the Taji mobile application, you agree to be bound by these terms and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using this app."),
        _buildSection(context, "2. User Accounts", "When you create an account, you must provide accurate and complete information. You are solely responsible for the activity that occurs on your account and must keep your account password secure."),
        _buildSection(context, "3. Products and Pricing", "We strive to display products as accurately as possible. However, we do not guarantee that product descriptions or prices are error-free. We reserve the right to correct any errors and to change or update information at any time."),
        _buildSection(context, "4. User Conduct", "You agree not to use the platform for any unlawful purpose, to transmit any harmful code, or to interfere with the proper working of the application."),
        _buildSection(context, "5. Intellectual Property", "All content, logos, graphics, and trademarks displayed on this app are the exclusive property of Taji or its licensors and are protected by copyright and trademark laws."),
        _buildSection(context, "6. Limitation of Liability", "Taji shall not be liable for any indirect, incidental, special, or consequential damages resulting from the use or the inability to use our services."),
        _buildSection(context, "7. Termination", "We may terminate or suspend your account and access to the service immediately, without prior notice or liability, for any reason whatsoever, including breach of terms."),
        _buildSection(context, "8. Governing Law", "These terms shall be governed and construed in accordance with the laws of Kenya, without regard to its conflict of law provisions."),
      ],
    );
  }

  Widget _buildAboutTaji(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(context, "Our Mission", "Taji is dedicated to making sustainable fashion accessible to everyone while promoting ethical shopping practices."),
        _buildSection(context, "Sustainability First", "We partner with local artisans and eco-conscious brands to bring you high-quality, long-lasting apparel."),
        _buildSection(context, "Join the Movement", "Discover a new way to shop that respects both style and the planet."),
      ],
    );
  }
}
