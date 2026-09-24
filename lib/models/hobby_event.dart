import 'package:geolocator/geolocator.dart';

import 'event_category.dart';
import 'event_venue.dart';
import 'geo_point.dart';

class HobbyEvent {
  const HobbyEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    required this.venueId,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.organizerName,
    required this.tags,
    this.imageUrl,
    this.isUserCreated = false,
  });

  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime dateTime;
  final String venueId;
  final int maxParticipants;
  final int currentParticipants;
  final String organizerName;
  final List<String> tags;
  final String? imageUrl;
  final bool isUserCreated;

  int get spotsLeft => maxParticipants - currentParticipants;

  bool get isAlmostFull => spotsLeft <= 3;

  double distanceKmFrom(GeoPoint user, EventVenue venue) {
    return Geolocator.distanceBetween(
          user.latitude,
          user.longitude,
          venue.latitude,
          venue.longitude,
        ) /
        1000;
  }

  String formattedDistanceFrom(GeoPoint user, EventVenue venue) {
    final km = distanceKmFrom(user, venue);
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  String locationLabel(EventVenue venue) => '${venue.name}, ${venue.shortAddress}';
}
