import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hobby_event.dart';
import '../providers/events_provider.dart';
import '../theme/app_theme.dart';
import 'check_in_scanner_screen.dart';
import 'event_check_in_qr_screen.dart';

class CheckInActions extends StatelessWidget {
  const CheckInActions({super.key, required this.event});

  final HobbyEvent event;

  @override
  Widget build(BuildContext context) {
    final checkedIn = context.watch<EventsProvider>().hasCheckedIn(event);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: checkedIn
              ? null
              : () async {
                  final confirmed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const CheckInScannerScreen(),
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Llegada confirmada. ¡Disfruta el evento!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
          icon: Icon(checkedIn ? Icons.verified : Icons.qr_code_scanner),
          label: Text(checkedIn ? 'Llegada confirmada' : 'Confirmar que llegué'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventCheckInQrScreen(event: event),
            ),
          ),
          icon: const Icon(Icons.qr_code_2),
          label: const Text('Mostrar QR del evento'),
        ),
        if (checkedIn) ...[
          const SizedBox(height: 8),
          Text(
            'Asistencia registrada a las ${_formatTime(context.read<EventsProvider>().checkedInAt(event))}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
