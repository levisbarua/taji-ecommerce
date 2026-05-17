import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final Map<String, bool> _settings = {
    "push_deals": true,
    "push_messages": true,
    "push_ads": true,
    "push_premium": true,
    "push_alerts": true,
    "push_viewed": true,
    "email_deals": true,
    "email_ads": true,
    "email_premium": true,
    "email_subs": true,
    "email_messages": true,
    "email_feedback": true,
    "sms_info": true,
  };

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
          "Manage notifications",
          style: TextStyle(color: tajiTextLight, fontSize: 18),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Push notifications"),
          _buildToggleItem("Hot deals, recommendations, news", "push_deals"),
          _buildToggleItem("Incoming messages from other users", "push_messages"),
          _buildToggleItem("Important information about your Ads, call to action", "push_ads"),
          _buildToggleItem("Premium package activation/expiration", "push_premium"),
          _buildToggleItem("Job alerts", "push_alerts"),
          _buildToggleItem("Viewed Ads", "push_viewed"),
          const SizedBox(height: 24),
          _buildSectionHeader("Email notifications"),
          _buildToggleItem("Hot deals and recommendations", "email_deals"),
          _buildToggleItem("Info about your Ads", "email_ads"),
          _buildToggleItem("Premium packages", "email_premium"),
          _buildToggleItem("Your subscriptions", "email_subs"),
          _buildToggleItem("Messages", "email_messages"),
          _buildToggleItem("Feedback", "email_feedback"),
          const SizedBox(height: 24),
          _buildToggleItem("SMS info notification", "sms_info"),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: tajiTextLight,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, String key) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _settings[key] = !(_settings[key] ?? false));
          },
          title: Text(
            title,
            style: TextStyle(
              color: tajiTextLight.withValues(alpha: 0.8),
              fontSize: 14,
              
            ),
          ),
          trailing: Switch(
            value: _settings[key] ?? false,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _settings[key] = val);
            },
            activeThumbColor: tajiSuccess,
            activeTrackColor: tajiSuccess.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: tajiTextLight.withValues(alpha: 0.05), height: 1),
        ),
      ],
    );
  }
}
