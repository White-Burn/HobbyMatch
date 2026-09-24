import 'package:latlong2/latlong.dart';

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  LatLng get latLng => LatLng(latitude, longitude);

  static const vinaDelMarCenter = GeoPoint(
    latitude: -33.0153,
    longitude: -71.5500,
  );
}
