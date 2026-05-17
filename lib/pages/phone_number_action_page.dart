import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class PhoneNumberActionPage extends StatefulWidget {
  final String method;
  const PhoneNumberActionPage({super.key, required this.method});

  @override
  State<PhoneNumberActionPage> createState() => _PhoneNumberActionPageState();
}

class _PhoneNumberActionPageState extends State<PhoneNumberActionPage> {
  final TextEditingController _numberController = TextEditingController();
  bool _showContinue = false;
  bool _isLoading = false;

  Future<void> _handleAction(VoidCallback onDone) async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      onDone();
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCall = widget.method == "Call";
    
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (isCall || _showContinue) ...[
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: pureWhite, fontSize: 20),
                decoration: InputDecoration(
                  labelText: "New phone number",
                  labelStyle: const TextStyle(color: pureYellow, fontSize: 18),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: pureYellow, width: 2)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: pureYellow, width: 2.5)),
                  suffixIcon: IconButton(icon: const Icon(Icons.cancel, color: tajiTextMutedDark), onPressed: () => _numberController.clear()),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            if (isCall && !_showContinue) ...[
              const Text(
                "We'll call you on your current number – 0715773232. It'll help us verify that there is no threat to your account",
                textAlign: TextAlign.center,
                style: TextStyle(color: pureWhite, fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleAction(() => setState(() => _showContinue = true)),
                  style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                    : const Text("Call me on 0715773232", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("It's free of charge", style: TextStyle(color: tajiTextMutedDark, fontSize: 16)),
            ] else if (widget.method == "SMS" && !_showContinue) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "We need to ensure that your account is safe",
                  style: TextStyle(color: pureWhite, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "We'll send an SMS confirmation code to your current number – 0715773232. It'll help us verify that the number currently linked to your account is still in your possession",
                textAlign: TextAlign.left,
                style: TextStyle(color: pureWhite, fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleAction(() => setState(() => _showContinue = true)),
                  style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                    : const Text("Send SMS code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text("It's free of charge", style: TextStyle(color: tajiTextMutedDark, fontSize: 16))),
            ] else if (_showContinue) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleAction(() {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification started..."), backgroundColor: pureYellow));
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: pureBlack, strokeWidth: 2))
                    : const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
