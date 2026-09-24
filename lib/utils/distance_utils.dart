import 'package:geolocator/geolocator.dart';

import '../models/geo_point.dart';

double distanceKmBetween(GeoPoint from, GeoPoint to) {
  return Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      ) /
      1000;
}

String formatDistanceKm(double distanceKm) {
  if (distanceKm < 1) {
    return '${(distanceKm * 1000).round()} m';
  }
  return '${distanceKm.toStringAsFixed(1)} km';
}

double parseRadiusKm(String radius) {
  final value = double.tryParse(radius.replaceAll(RegExp(r'[^0-9.]'), ''));
  return value ?? 5;
}
