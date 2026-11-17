import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/geo_point.dart';
import '../models/hobby_event.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/check_in_actions.dart';
import '../widgets/event_card.dart';
import '../widgets/event_map_widget.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final HobbyEvent event;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("EEEE d 'de' MMMM · HH:mm", 'es');
    final provider = context.read<EventsProvider>();
    final user = context.watch<LocationProvider>().position;
    final venue = provider.venueFor(event);
    final isLiked = provider.likedEvents.any((e) => e.id == event.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: EventCard(event: event)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  _DetailRow(icon: Icons.calendar_today, text: dateFormat.format(event.dateTime)),
                  _DetailRow(icon: Icons.location_on, text: '${venue.name} · ${provider.eventDistanceLabel(event, user)}'),
                  _DetailRow(icon: Icons.place, text: venue.address),
                  _DetailRow(icon: Icons.people, text: '${event.currentParticipants} de ${event.maxParticipants} participantes · ${event.spotsLeft} cupos'),
                  _DetailRow(icon: Icons.person, text: 'Organiza: ${event.organizerName}'),
                  const SizedBox(height: 16),
                  Text('Ubicación', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  EventMapWidget(
                    center: GeoPoint(latitude: venue.latitude, longitude: venue.longitude),
                    userPosition: user,
                    venues: [venue],
                    events: [event],
                    selectedVenueId: venue.id,
                    height: 180,
                    interactive: false,
                  ),
                  const SizedBox(height: 20),
                  const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(event.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 15)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.tags.map((tag) => Chip(label: Text(tag), backgroundColor: event.category.color.withOpacity(0.12), labelStyle: TextStyle(color: event.category.color, fontWeight: FontWeight.w600), side: BorderSide.none)).toList(),
                  ),
                  const SizedBox(height: 24),
                  CheckInActions(event: event),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isLiked ? null : () {
                        provider.likeEvent(event);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Te uniste a "${event.title}"'), behavior: SnackBarBehavior.floating));
                      },
                      icon: Icon(isLiked ? Icons.check : Icons.favorite),
                      label: Text(isLiked ? 'Ya te interesa' : 'Me interesa'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4))),
          ],
        ),
      );
}
