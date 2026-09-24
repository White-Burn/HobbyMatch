import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/events_provider.dart';
import '../theme/app_theme.dart';

class CheckInScannerScreen extends StatefulWidget {
  const CheckInScannerScreen({super.key});

  @override
  State<CheckInScannerScreen> createState() => _CheckInScannerScreenState();
}

class _CheckInScannerScreenState extends State<CheckInScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (rawValue == null) return;

    final uri = Uri.tryParse(rawValue);
    final eventId = uri?.queryParameters['eventId'];
    final token = uri?.queryParameters['token'];
    if (eventId == null || token == null) {
      setState(() => _error = 'El código no corresponde a HobbyMatch.');
      return;
    }

    final provider = context.read<EventsProvider>();
    final valid = provider.confirmAttendance(eventId: eventId, token: token);
    if (!valid) {
      setState(() => _error = 'El código no es válido para este evento.');
      return;
    }

    _processing = true;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar llegada')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Apunta al código QR que muestra el organizador',
                      textAlign: TextAlign.center,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: TextStyle(color: AppColors.primary)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
