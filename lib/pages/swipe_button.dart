import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class SwipeButton extends StatefulWidget {
  final VoidCallback onSwipe;
  const SwipeButton({super.key, required this.onSwipe});

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = constraints.maxWidth / 2;
        double maxSlide = constraints.maxWidth - buttonWidth - 12;

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.all(6),
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: buttonWidth),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_right, color: tajiTextLight.withValues(alpha: 0.3), size: 28),
                          Icon(Icons.chevron_right, color: tajiTextLight.withValues(alpha: 0.6), size: 28),
                          const Icon(Icons.chevron_right, color: tajiTextLight, size: 28),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),

              Positioned(
                left: _dragValue * maxSlide,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragValue += details.delta.dx / maxSlide;
                      _dragValue = _dragValue.clamp(0.0, 1.0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragValue > 0.8) {
                      HapticFeedback.heavyImpact();
                      widget.onSwipe();
                    }
                    setState(() {
                      _dragValue = 0.0;
                    });
                  },
                  child: Container(
                    width: buttonWidth,
                    height: 68,
                    decoration: BoxDecoration(
                      color: pureYellow,
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: const Center(
                      child: Text(
                        'Swipe to start',
                        style: TextStyle(
                          color: pureBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
