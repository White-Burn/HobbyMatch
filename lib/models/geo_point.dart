import 'package:latlong2/latlong.dart';

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  LatLng get latLng => LatLng(latitude, longitude);

  static const santiagoCenter = GeoPoint(
    latitude: -33.4489,
    longitude: -70.6693,
  );
}
