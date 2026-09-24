import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event_venue.dart';
import '../models/geo_point.dart';
import '../models/hobby_event.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';
import '../utils/distance_utils.dart';
import '../widgets/event_map_widget.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedVenueId;

  EventVenue? _findVenue(EventsProvider events, String? id) {
    if (id == null) return null;
    for (final venue in events.venues) {
      if (venue.id == id) return venue;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final events = context.watch<EventsProvider>();
    final user = location.position;
    final nearbyEvents = events.filteredEventsNear(user);
    final radiusKm = parseRadiusKm(events.searchRadius);
    final selectedVenue = _findVenue(events, _selectedVenueId);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mapa de espacios',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              location.hasRealLocation ? Icons.gps_fixed : Icons.gps_off,
                              size: 14,
                              color: location.hasRealLocation
                                  ? AppColors.like
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location.statusLabel,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: location.refreshLocation,
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Actualizar GPS',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventMapWidget(
                  center: selectedVenue != null
                      ? GeoPoint(
                          latitude: selectedVenue.latitude,
                          longitude: selectedVenue.longitude,
                        )
                      : user,
                  userPosition: user,
                  venues: events.venues,
                  events: nearbyEvents,
                  selectedVenueId: _selectedVenueId,
                  height: double.infinity,
                  onVenueTap: (venue) => setState(() => _selectedVenueId = venue.id),
                  onEventTap: (event) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: event),
                    ),
                  ),
                ),
              ),
            ),
            if (selectedVenue != null)
              _VenuePanel(
                venue: selectedVenue,
                user: user,
                onCreate: () => _openCreateEvent(selectedVenue),
              )
            else
              _EventsPanel(
                events: nearbyEvents,
                radiusKm: radiusKm,
                onEventTap: (event) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(event: event),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateEvent(selectedVenue),
        icon: const Icon(Icons.add),
        label: const Text('Crear evento'),
      ),
    );
  }

  void _openCreateEvent(EventVenue? preselected) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateEventScreen(preselectedVenueId: preselected?.id),
      ),
    );
  }
}

class _VenuePanel extends StatelessWidget {
  const _VenuePanel({
    required this.venue,
    required this.user,
    required this.onCreate,
  });

  final EventVenue venue;
  final GeoPoint user;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final distance = formatDistanceKm(
      distanceKmBetween(
        user,
        GeoPoint(latitude: venue.latitude, longitude: venue.longitude),
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(venue.type.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    Text(
                      '$distance · ${venue.type.label}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(venue.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (venue.amenities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: venue.amenities
                  .map(
                    (a) => Chip(
                      label: Text(a, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.event),
              label: const Text('Crear evento aquí'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsPanel extends StatelessWidget {
  const _EventsPanel({
    required this.events,
    required this.radiusKm,
    required this.onEventTap,
  });

  final List<HobbyEvent> events;
  final double radiusKm;
  final ValueChanged<HobbyEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${events.length} eventos dentro de ${radiusKm.toStringAsFixed(0)} km',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text(
                      'No hay eventos cerca. ¡Crea uno!',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final provider = context.read<EventsProvider>();
                      final user = context.read<LocationProvider>().position;
                      final venue = provider.venueFor(event);

                      return GestureDetector(
                        onTap: () => onEventTap(event),
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: event.category.color.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(event.category.icon,
                                      size: 16, color: event.category.color),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                venue.shortAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                provider.eventDistanceLabel(event, user),
                                style: TextStyle(
                                  color: event.category.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
