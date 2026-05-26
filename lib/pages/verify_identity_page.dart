import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class VerifyIdentityPage extends StatefulWidget {
  final bool isEmailChange;
  const VerifyIdentityPage({super.key, this.isEmailChange = false});

  @override
  State<VerifyIdentityPage> createState() => _VerifyIdentityPageState();
}

class _VerifyIdentityPageState extends State<VerifyIdentityPage> {
  String selectedDocType = "Passport";
  final TextEditingController _docIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  DateTime? selectedDate;
  bool _isLoading = false;
  File? _docPhoto;

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _docPhoto = File(image.path));
    }
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Identity verification is not yet available. Your data was not saved server-side."),
        backgroundColor: tajiAmber,
      ));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _docIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _showDocTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A202C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final docTypes = ["Passport", "Passport international", "Alien Card / Foreigner Certificate", "National ID", "Drivers Licence"];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: RadioGroup<String>(
                groupValue: selectedDocType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selectedDocType = val);
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...docTypes.map((type) => ListTile(
                          title: Text(type, style: const TextStyle(color: pureWhite)),
                          trailing: Radio<String>(
                            value: type,
                            activeColor: pureYellow,
                          ),
                          onTap: () {
                            setState(() => selectedDocType = type);
                            Navigator.pop(context);
                          },
                        )),
                  ],
                ),
              ),
        );
      },
    );
  }

  void _showDocIdHelp() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A202C),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text("Where to find Document ID?", style: TextStyle(color: pureWhite, fontSize: 14)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: pureWhite), 
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  }
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Container(
                  decoration: BoxDecoration(color: tajiTextLight, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Icon(Icons.image, size: 50, color: tajiTextMutedDark)), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Verify your identity with ID", style: TextStyle(color: pureWhite, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(widget.isEmailChange ? "To change your email" : "To change your phone number", style: TextStyle(color: pureWhite.withValues(alpha: 0.6), fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: pureWhite, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPickerField("Choose doc type*", selectedDocType, _showDocTypePicker),
            const SizedBox(height: 16),
            _buildTextField("Document ID*", _docIdController, keyboardType: TextInputType.text, counter: "0/9"),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showDocIdHelp,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF1E2A1E), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: pureYellow, size: 24),
                    SizedBox(width: 8),
                    Text("Where to find Document ID?", style: TextStyle(color: pureYellow, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField("First Name*", _firstNameController, counter: "0/100"),
            const SizedBox(height: 16),
            _buildTextField("Last Name*", _lastNameController, counter: "0/100"),
            const SizedBox(height: 16),
            _buildTextField(widget.isEmailChange ? "New E-mail address*" : "New phone number*", _numberController, keyboardType: widget.isEmailChange ? TextInputType.emailAddress : TextInputType.phone),
            const SizedBox(height: 16),
            _buildPickerField("Date of birth*", selectedDate == null ? "" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}", _selectDate),
            const SizedBox(height: 24),
            Text("Attach photo of your $selectedDocType*", style: const TextStyle(color: pureWhite, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: tajiTextLight.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: pureWhite.withValues(alpha: 0.1)),
                  ),
                  child: _docPhoto != null
                      ? Image.file(_docPhoto!, fit: BoxFit.cover)
                      : const Icon(Icons.add, color: pureYellow, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text("Use .jpg, .jpeg, .png, .heic", style: TextStyle(color: tajiTextMutedDark, fontSize: 12)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                  : const Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Please note, by submitting any information and documents to our customer support you consent to the processing of such data for use in identification and authentication and you acknowledge that such processing is also required to continue providing our services to you",
              style: TextStyle(color: pureWhite.withValues(alpha: 0.5), fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, String? counter}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: pureWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: pureWhite.withValues(alpha: 0.5)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: pureWhite.withValues(alpha: 0.15), width: 1.5)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: pureYellow, width: 2)),
        helperText: counter,
        helperStyle: const TextStyle(color: tajiTextMutedDark, fontSize: 14),
      ),
    );
  }

  Widget _buildPickerField(String label, String value, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: pureWhite.withValues(alpha: 0.15), width: 1.5), 
            borderRadius: BorderRadius.circular(4)
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: pureWhite.withValues(alpha: 0.6), fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(value, style: const TextStyle(color: pureWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: tajiTextMutedDark),
            ],
          ),
        ),
      ),
    );
  }
}
