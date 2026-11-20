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

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'dateTime': dateTime.toIso8601String(),
        'venueId': venueId,
        'maxParticipants': maxParticipants,
        'currentParticipants': currentParticipants,
        'organizerName': organizerName,
        'tags': tags,
        'imageUrl': imageUrl,
        'isUserCreated': isUserCreated,
      };

  factory HobbyEvent.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    final category = EventCategory.values.firstWhere(
      (value) => value.name == categoryName,
      orElse: () => EventCategory.meetup,
    );
    return HobbyEvent(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: category,
      dateTime: DateTime.parse(json['dateTime'] as String),
      venueId: json['venueId'] as String? ?? '',
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 2,
      currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 1,
      organizerName: json['organizerName'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.whereType<String>().toList() ?? const [],
      imageUrl: json['imageUrl'] as String?,
      isUserCreated: json['isUserCreated'] as bool? ?? true,
    );
  }

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
