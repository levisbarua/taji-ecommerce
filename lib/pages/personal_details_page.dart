import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import '../services/managers.dart';

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final TextEditingController _firstNameController = TextEditingController(text: "");
  final TextEditingController _lastNameController = TextEditingController(text: "");
  
  String _location = "";
  String _birthday = "";
  String _sex = "";
  bool _isGoogleConnected = true;
  bool _isFacebookConnected = false;
  
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ProfileManager.getProfileData();
    setState(() {
      _firstNameController.text = data['firstName']!;
      _lastNameController.text = data['lastName']!;
      _location = data['location']!;
      _birthday = data['birthday']!;
      _sex = data['sex']!;
      if (data['image']!.isNotEmpty) {
        _imageFile = XFile(data['image']!);
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() {
        _imageFile = selected;
      });
    }
  }

  void _showLocationPicker() {
    final cities = ["Nairobi City, Kenya", "Mombasa, Kenya", "Kisumu, Kenya", "Nakuru, Kenya", "Eldoret, Kenya"];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: cities.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(cities[index], style: const TextStyle(color: tajiTextLight)),
          onTap: () {
            setState(() => _location = cities[index]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showSexPicker() {
    final genders = ["Male", "Female", "Other"];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: genders.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(genders[index], style: const TextStyle(color: tajiTextLight)),
          onTap: () {
            setState(() => _sex = genders[index]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 12),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: pureYellow,
              onPrimary: pureBlack,
              surface: Color(0xFF1A202C),
              onSurface: pureWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      setState(() {
        _birthday = "${months[picked.month - 1]} ${picked.day}, ${picked.year}";
      });
    }
  }

  Future<void> _saveAll() async {
    await ProfileManager.savePersonalDetails(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      location: _location,
      birthday: _birthday,
      sex: _sex,
      image: _imageFile?.path,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All changes saved successfully!", style: TextStyle( color: pureBlack)),
        backgroundColor: pureYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Personal details",
          style: TextStyle(color: pureWhite, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: const Text("Save", style: TextStyle(color: pureYellow, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: tajiDarkSurface,
                          backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                          child: _imageFile == null ? Icon(Icons.person, size: 60, color: tajiTextMutedDark) : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: pureYellow, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: pureBlack, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildDetailField("First Name", _firstNameController),
            const SizedBox(height: 24),
            _buildDetailField("Last Name", _lastNameController),
            const SizedBox(height: 24),
            _buildSelectableField("Location", _location, onTap: _showLocationPicker),
            const SizedBox(height: 24),
            _buildSelectableField("Birthday", _birthday, onTap: _showDatePicker),
            const SizedBox(height: 24),
            _buildSelectableField("Sex", _sex, onTap: _showSexPicker),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: pureWhite.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👍", style: TextStyle(fontSize: 24)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rest assured, your data is protected.",
                          style: TextStyle(color: pureWhite, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "We value your privacy and only use this information to personalize your experience.",
                          style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "CONNECTED ACCOUNTS",
                style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 16),
            _buildSocialSwitch(
              "Google", 
              Image.asset('assets/images/google_logo.png', width: 20, height: 20), 
              _isGoogleConnected,
              onChanged: (v) => setState(() => _isGoogleConnected = v),
            ),
            _buildSocialSwitch(
              "Facebook", 
              const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 24), 
              _isFacebookConnected,
              onChanged: (v) => setState(() => _isFacebookConnected = v),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pureYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "SAVE ALL CHANGES",
                  style: TextStyle(color: pureBlack, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: pureWhite, fontSize: 16),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: pureWhite.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: pureYellow),
            ),
            filled: true,
            fillColor: pureWhite.withValues(alpha: 0.02),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableField(String label, String value, {VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 13)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: pureWhite.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pureWhite.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(color: pureWhite, fontSize: 16)),
                const Icon(Icons.chevron_right, color: Color(0x66FFFFFF), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSwitch(String name, Widget icon, bool value, {required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: pureWhite.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
            child: icon,
          ),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(color: pureWhite, fontSize: 16)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: pureYellow,
            activeThumbColor: pureBlack,
          ),
        ],
      ),
    );
  }
}
