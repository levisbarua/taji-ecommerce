import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import '../services/user_session.dart';
import '../services/managers.dart';
import 'my_orders_page.dart';
import 'address_list_page.dart';
import 'wishlist_page.dart';
import 'settings_page.dart';
import 'contact_support_page.dart';
import 'info_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userEmail;
  String _userName = 'Sarah Jenkins';
  XFile? _profileImage;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }


  Future<void> _loadProfileData() async {
    final sessionEmail = await UserSession.getEmail();
    final data = await ProfileManager.getProfileData();
    final premium = await GlobalSettingsManager.isPremium();
    setState(() {
      _userEmail = sessionEmail ?? data['email']!;
      final fName = data['firstName'] ?? '';
      final lName = data['lastName'] ?? '';
      _userName = (fName.isEmpty && lName.isEmpty) ? data['name']! : "$fName $lName";
      _isPremium = premium;
      if (data['image']!.isNotEmpty) {
        _profileImage = XFile(data['image']!);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? pureBlack : pureBlack.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          Text(
                            "Profile",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -60),
              child: Column(
                children: [
                  Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        image: _profileImage != null
                          ? DecorationImage(image: FileImage(File(_profileImage!.path)), fit: BoxFit.cover)
                          : null,
                      ),
                      child: _profileImage == null
                        ? Center(
                            child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onSurface),
                          )
                        : null,
                    ),
                  const SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _userName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: pureYellow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "PRO",
                                  style: TextStyle(color: pureBlack, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _userEmail ?? "Loading...",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                      );
                    },
                    child: _buildProfileItem(context, Icons.shopping_bag_outlined, "My Orders"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddressListPage()),
                      );
                    },
                    child: _buildProfileItem(context, Icons.location_on_outlined, "Shipping Addresses"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WishlistPage()),
                      );
                    },
                    child: _buildProfileItem(context, Icons.favorite_border, "Wishlist"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      ).then((_) => _loadProfileData());
                    },
                    child: _buildProfileItem(context, Icons.settings_outlined, "Settings"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactSupportPage()),
                      );
                    },
                    child: _buildProfileItem(context, Icons.support_agent_outlined, "Contact Support"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InfoPage(title: "Help Center")), 
                      );
                    },
                    child: _buildProfileItem(context, Icons.help_outline, "Help Center"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InfoPage(title: "Privacy Policy")),
                      );
                    },
                    child: _buildProfileItem(context, Icons.privacy_tip_outlined, "Privacy Policy"),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileItem(BuildContext context, IconData icon, String title, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.01)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLogout ? pureYellow.withValues(alpha: 0.2) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isLogout ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (!isLogout)
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }
}
