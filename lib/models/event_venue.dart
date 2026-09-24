enum VenueType {
  court('Cancha deportiva', '🏀'),
  field('Campo / cancha grande', '⚽'),
  park('Parque / outdoor', '🌳'),
  indoor('Espacio indoor', '🏢'),
  social('Bar / café / social', '🍻'),
  gaming('Sala gaming', '🎮');

  const VenueType(this.label, this.emoji);

  final String label;
  final String emoji;
}

class EventVenue {
  const EventVenue({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.amenities = const [],
    this.capacity = 30,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final VenueType type;
  final List<String> amenities;
  final int capacity;

  String get shortAddress => address.split(',').first.trim();
}
