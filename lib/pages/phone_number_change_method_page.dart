import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import 'phone_number_action_page.dart';
import 'verify_identity_page.dart';

class PhoneNumberChangeMethodPage extends StatelessWidget {
  const PhoneNumberChangeMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Change phone number", style: TextStyle(color: pureWhite, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildMethodTile(
            context,
            Icons.call_outlined,
            "Answer a call",
            "on 0715773232",
            () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneNumberActionPage(method: "Call")));
            },
          ),
          const SizedBox(height: 16),
          _buildMethodTile(
            context,
            Icons.message_outlined,
            "Receive SMS",
            "on 0715773232",
            () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneNumberActionPage(method: "SMS")));
            },
          ),
          const SizedBox(height: 16),
          _buildMethodTile(
            context,
            Icons.attach_file_outlined,
            "Attach your ID",
            "if you lost the number",
            () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyIdentityPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: pureWhite.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(icon, color: pureYellow, size: 30),
            title: Text(title, style: const TextStyle(color: pureWhite, fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle, style: TextStyle(color: pureWhite.withValues(alpha: 0.6), fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: pureWhite, size: 28),
          ),
        ),
      ),
    );
  }
}
