import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import '../../l10n/l10n.dart';

/// Barcode Scanner — animated scan frame, a repeating light sweep,
/// haptic/sound confirmation on a successful read (simulated here).
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);
  bool _found = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _simulateScan() {
    setState(() => _found = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white)),
                const Spacer(),
                Text(context.l10n.barcodeTitle,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _simulateScan,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 260,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  _found ? AppColors.accentGreen : Colors.white,
                              width: 3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      if (!_found)
                        AnimatedBuilder(
                          animation: _c,
                          builder: (context, _) => Positioned(
                            top: 10 + _c.value * 160,
                            child: Container(
                                width: 240,
                                height: 2,
                                color:
                                    AppColors.primary.withValues(alpha: 0.9)),
                          ),
                        ),
                      if (_found)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.accentGreen, size: 48),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _found ? context.l10n.barcodeFound : context.l10n.barcodeHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
