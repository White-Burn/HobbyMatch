import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';

import '../models/hobby_event.dart';
import '../providers/events_provider.dart';
import '../theme/app_theme.dart';

class EventCheckInQrScreen extends StatelessWidget {
  const EventCheckInQrScreen({super.key, required this.event});

  final HobbyEvent event;

  @override
  Widget build(BuildContext context) {
    final payload = context.read<EventsProvider>().checkInPayload(event);
    return Scaffold(
      appBar: AppBar(title: const Text('Código de asistencia')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.how_to_reg, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                event.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Muestra este código a las personas al llegar al evento.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: QrImageView(
                    data: payload,
                    version: QrVersions.auto,
                    size: 260,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Este QR es un prototipo local. Para producción debe ser temporal y validado por un backend.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
