import 'package:flutter/foundation.dart';

import '../data/mock_events.dart';
import '../data/predefined_venues.dart';
import '../models/event_category.dart';
import '../models/event_venue.dart';
import '../models/geo_point.dart';
import '../models/hobby_event.dart';
import '../models/user_profile.dart';
import '../utils/distance_utils.dart';

class EventsProvider extends ChangeNotifier {
  EventsProvider() {
    _availableEvents = List.from(mockEvents);
  }

  late List<HobbyEvent> _availableEvents;
  final List<HobbyEvent> _likedEvents = [];
  final List<HobbyEvent> _passedEvents = [];
  final List<HobbyEvent> _userCreatedEvents = [];
  EventCategory? _selectedCategory;
  String _searchRadius = '5 km';
  int _nextEventId = 100;

  List<HobbyEvent> get availableEvents => _availableEvents;
  List<HobbyEvent> get likedEvents => List.unmodifiable(_likedEvents);
  List<HobbyEvent> get passedEvents => List.unmodifiable(_passedEvents);
  List<HobbyEvent> get userCreatedEvents => List.unmodifiable(_userCreatedEvents);
  EventCategory? get selectedCategory => _selectedCategory;
  String get searchRadius => _searchRadius;
  List<EventVenue> get venues => predefinedVenues;

  List<HobbyEvent> get allEvents => [
        ..._availableEvents,
        ..._likedEvents,
        ..._userCreatedEvents,
      ];

  EventVenue venueFor(HobbyEvent event) {
    return venueById(event.venueId) ?? predefinedVenues.first;
  }

  double eventDistanceKm(HobbyEvent event, GeoPoint user) {
    return event.distanceKmFrom(user, venueFor(event));
  }

  String eventDistanceLabel(HobbyEvent event, GeoPoint user) {
    return event.formattedDistanceFrom(user, venueFor(event));
  }

  List<HobbyEvent> eventsNearUser(GeoPoint user, {bool includePassed = false}) {
    final radiusKm = parseRadiusKm(_searchRadius);
    final pool = includePassed
        ? [..._availableEvents, ..._likedEvents, ..._userCreatedEvents]
        : [..._availableEvents, ..._userCreatedEvents];

    return pool.where((event) {
      final distance = eventDistanceKm(event, user);
      return distance <= radiusKm;
    }).toList()
      ..sort(
        (a, b) => eventDistanceKm(a, user).compareTo(eventDistanceKm(b, user)),
      );
  }

  List<HobbyEvent> get filteredEvents {
    // Will be filtered with location in UI layer or via method
    var events = List<HobbyEvent>.from(_availableEvents);

    if (_selectedCategory != null) {
      events = events.where((e) => e.category == _selectedCategory).toList();
    }

    return events;
  }

  List<HobbyEvent> filteredEventsNear(GeoPoint user) {
    final radiusKm = parseRadiusKm(_searchRadius);
    var events = filteredEvents.where((event) {
      return eventDistanceKm(event, user) <= radiusKm;
    }).toList();

    events.sort(
      (a, b) => eventDistanceKm(a, user).compareTo(eventDistanceKm(b, user)),
    );

    return events;
  }

  void setCategory(EventCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchRadius(String radius) {
    _searchRadius = radius;
    notifyListeners();
  }

  void likeEvent(HobbyEvent event) {
    _availableEvents.removeWhere((e) => e.id == event.id);
    if (!_likedEvents.any((e) => e.id == event.id)) {
      _likedEvents.insert(0, event);
    }
    notifyListeners();
  }

  void passEvent(HobbyEvent event) {
    _availableEvents.removeWhere((e) => e.id == event.id);
    if (!_passedEvents.any((e) => e.id == event.id)) {
      _passedEvents.add(event);
    }
    notifyListeners();
  }

  void removeFromLiked(HobbyEvent event) {
    _likedEvents.removeWhere((e) => e.id == event.id);
    notifyListeners();
  }

  HobbyEvent createEvent({
    required String title,
    required String description,
    required EventCategory category,
    required DateTime dateTime,
    required String venueId,
    required int maxParticipants,
    List<String> tags = const [],
  }) {
    final event = HobbyEvent(
      id: 'user-${_nextEventId++}',
      title: title,
      description: description,
      category: category,
      dateTime: dateTime,
      venueId: venueId,
      maxParticipants: maxParticipants,
      currentParticipants: 1,
      organizerName: UserProfile.demo.name,
      tags: tags,
      isUserCreated: true,
    );

    _userCreatedEvents.insert(0, event);
    _availableEvents.insert(0, event);
    notifyListeners();
    return event;
  }

  void resetDeck() {
    _availableEvents = [
      ..._userCreatedEvents,
      ...mockEvents,
    ];
    _likedEvents.clear();
    _passedEvents.clear();
    notifyListeners();
  }
}
