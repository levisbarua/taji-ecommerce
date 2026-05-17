import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class ChatSettingsPage extends StatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  bool _receiveMessages = true;

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
          "Chat settings",
          style: TextStyle(color: tajiTextLight, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ListTile(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _receiveMessages = !_receiveMessages);
            },
            title: const Text(
              "Receive messages",
              style: TextStyle(color: tajiTextLight, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Switch(
              value: _receiveMessages,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _receiveMessages = val);
              },
              activeThumbColor: tajiSuccess,
              activeTrackColor: tajiSuccess.withValues(alpha: 0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: tajiTextLight.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Chats help your customers to get in touch with you through messages on Taji platform.\n\nDisable this option if you don't want to reply to the messages (Your existed chats stay active).",
              style: TextStyle(
                color: tajiTextLight.withValues(alpha: 0.6),
                fontSize: 14,
                
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: tajiTextLight.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "If you don't reply to your customers for a while, chats will be turn Off automatically (Your existed chats stay active).",
              style: TextStyle(
                color: tajiTextLight.withValues(alpha: 0.6),
                fontSize: 14,
                
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
