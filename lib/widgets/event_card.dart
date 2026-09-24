import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/hobby_event.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final HobbyEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = event.category;
    final dateFormat = DateFormat("EEE d MMM · HH:mm", 'es');
    final events = context.watch<EventsProvider>();
    final user = context.watch<LocationProvider>().position;
    final venue = events.venueFor(event);
    final distanceLabel = events.eventDistanceLabel(event, user);
    final locationLabel = venue.shortAddress;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _GradientBackground(category: category),
              _CategoryBadge(category: category),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _EventInfo(
                  event: event,
                  dateFormat: dateFormat,
                  distanceLabel: distanceLabel,
                  locationLabel: locationLabel,
                ),              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({required this.category});

  final dynamic category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color,
            category.color.withOpacity(0.7),
            const Color(0xFF1A1A2E),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          category.icon,
          size: 120,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final dynamic category;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  const _EventInfo({
    required this.event,
    required this.dateFormat,
    required this.distanceLabel,
    required this.locationLabel,
  });

  final HobbyEvent event;
  final DateFormat dateFormat;
  final String distanceLabel;
  final String locationLabel;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.85),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.accent, size: 16),
              const SizedBox(width: 4),
              Text(
                '$distanceLabel · $locationLabel',                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
              if (event.isAlmostFull) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '¡Casi lleno!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dateFormat.format(event.dateTime),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(
                icon: Icons.people_outline,
                label: '${event.currentParticipants}/${event.maxParticipants}',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.person_outline,
                label: event.organizerName,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: event.tags
                .take(3)
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
