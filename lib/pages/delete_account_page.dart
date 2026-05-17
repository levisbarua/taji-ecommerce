import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  String _selectedReason = "I get too many notifications";

  final List<String> _reasons = [
    "I want to change phone number",
    "I want to change email address",
    "I've already sold my items",
    "I have a duplicate account",
    "I haven't found anything interesting on Jiji",
    "I get too many notifications",
    "Other",
  ];

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
          "Delete my account permanently",
          style: TextStyle(color: tajiTextLight, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Oh no... Why would you like to delete your account?",
                  style: TextStyle(
                    color: tajiTextLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "If you delete your account now, you'll lose access to all data, including your profile, chat and ad history, followers, and reviews. There is no way to recover it after completing this action",
                  style: TextStyle(
                    color: tajiTextLight.withValues(alpha: 0.5),
                    fontSize: 14,
                    height: 1.4,
                    
                  ),
                ),
                const SizedBox(height: 24),
                ..._reasons.map((reason) => _buildReasonItem(reason)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                },
                icon: const Icon(Icons.heart_broken_rounded, color: tajiTextDark, size: 20),
                label: const Text(
                  "Delete my account permanently",
                  style: TextStyle(
                    color: tajiTextDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF87171),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonItem(String reason) {
    bool isSelected = _selectedReason == reason;
    return Column(
      children: [
        ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedReason = reason);
          },
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? tajiSuccess : tajiTextLight.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: tajiSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          title: Text(
            reason,
            style: TextStyle(
              color: tajiTextLight.withValues(alpha: 0.9),
              fontSize: 15,
              
            ),
          ),
        ),
        Divider(color: tajiTextLight.withValues(alpha: 0.05), height: 1),
      ],
    );
  }
}
