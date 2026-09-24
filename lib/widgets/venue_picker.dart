import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event_venue.dart';
import '../models/geo_point.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';
import '../utils/distance_utils.dart';

class VenuePicker extends StatelessWidget {
  const VenuePicker({
    super.key,
    required this.selectedVenueId,
    required this.onSelected,
    this.sortByDistance = true,
  });

  final String? selectedVenueId;
  final ValueChanged<EventVenue> onSelected;
  final bool sortByDistance;

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final user = context.watch<LocationProvider>().position;

    var venues = List<EventVenue>.from(eventsProvider.venues);
    if (sortByDistance) {
      venues.sort((a, b) {
        final distA = distanceKmBetween(
          user,
          GeoPoint(latitude: a.latitude, longitude: a.longitude),
        );
        final distB = distanceKmBetween(
          user,
          GeoPoint(latitude: b.latitude, longitude: b.longitude),
        );
        return distA.compareTo(distB);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Espacio del evento',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...venues.map((venue) {
          final selected = venue.id == selectedVenueId;
          final distance = formatDistanceKm(
            distanceKmBetween(
              user,
              GeoPoint(latitude: venue.latitude, longitude: venue.longitude),
            ),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: selected
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onSelected(venue),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.15),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(venue.type.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venue.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              venue.address,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${venue.type.label} · $distance · hasta ${venue.capacity} pers.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
