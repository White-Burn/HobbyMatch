import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/event_venue.dart';
import '../models/geo_point.dart';
import '../models/hobby_event.dart';
import '../providers/events_provider.dart';
import '../theme/app_theme.dart';
import '../utils/distance_utils.dart';

class EventMapWidget extends StatelessWidget {
  const EventMapWidget({
    super.key,
    required this.center,
    this.userPosition,
    this.venues = const [],
    this.events = const [],
    this.selectedVenueId,
    this.onVenueTap,
    this.onEventTap,
    this.height = 220,
    this.interactive = true,
    this.showUserLocation = true,
  });

  final GeoPoint center;
  final GeoPoint? userPosition;
  final List<EventVenue> venues;
  final List<HobbyEvent> events;
  final String? selectedVenueId;
  final ValueChanged<EventVenue>? onVenueTap;
  final ValueChanged<HobbyEvent>? onEventTap;
  final double height;
  final bool interactive;
  final bool showUserLocation;

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.read<EventsProvider>();
    final location = userPosition ?? center;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center.latLng,
            initialZoom: 13,
            interactionOptions: InteractionOptions(
              flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hobbymatch.app',
            ),
            if (showUserLocation && userPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: userPosition!.latLng,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: const Icon(Icons.my_location, color: AppColors.accent, size: 18),
                    ),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final venue in venues)
                  _venueMarker(venue, location),
                for (final event in events)
                  _eventMarker(event, location, eventsProvider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Marker _venueMarker(EventVenue venue, GeoPoint user) {
    final isSelected = venue.id == selectedVenueId;
    final distance = formatDistanceKm(
      distanceKmBetween(
        user,
        GeoPoint(latitude: venue.latitude, longitude: venue.longitude),
      ),
    );

    return Marker(
      point: LatLng(venue.latitude, venue.longitude),
      width: isSelected ? 44 : 36,
      height: isSelected ? 44 : 36,
      child: GestureDetector(
        onTap: () => onVenueTap?.call(venue),
        child: Tooltip(
          message: '${venue.name} · $distance',
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(venue.type.emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  Marker _eventMarker(
    HobbyEvent event,
    GeoPoint user,
    EventsProvider provider,
  ) {
    final venue = provider.venueFor(event);
    final distance = provider.eventDistanceLabel(event, user);

    return Marker(
      point: LatLng(venue.latitude, venue.longitude),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => onEventTap?.call(event),
        child: Tooltip(
          message: '${event.title} · $distance',
          child: Container(
            decoration: BoxDecoration(
              color: event.category.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: event.category.color.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(event.category.icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
