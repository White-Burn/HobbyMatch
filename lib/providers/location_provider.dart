import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/geo_point.dart';
import '../services/location_service.dart';

enum LocationStatus {
  loading,
  granted,
  denied,
  serviceDisabled,
}

class LocationProvider extends ChangeNotifier {
  LocationProvider({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  final LocationService _locationService;

  LocationStatus _status = LocationStatus.loading;
  GeoPoint _position = GeoPoint.santiagoCenter;
  String? _errorMessage;

  LocationStatus get status => _status;
  GeoPoint get position => _position;
  String? get errorMessage => _errorMessage;
  bool get hasRealLocation => _status == LocationStatus.granted;

  String get statusLabel {
    switch (_status) {
      case LocationStatus.loading:
        return 'Obteniendo ubicación...';
      case LocationStatus.granted:
        return 'GPS activo';
      case LocationStatus.denied:
        return 'Sin permiso GPS · usando Santiago';
      case LocationStatus.serviceDisabled:
        return 'GPS desactivado · usando Santiago';
    }
  }

  Future<void> initialize() => refreshLocation();

  Future<void> refreshLocation() async {
    _status = LocationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final serviceEnabled = await _locationService.isServiceEnabled();
      if (!serviceEnabled) {
        _status = LocationStatus.serviceDisabled;
        _position = GeoPoint.santiagoCenter;
        notifyListeners();
        return;
      }

      var permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _status = LocationStatus.denied;
        _position = GeoPoint.santiagoCenter;
        notifyListeners();
        return;
      }

      final point = await _locationService.getCurrentPosition();
      if (point != null) {
        _position = point;
        _status = LocationStatus.granted;
      } else {
        _status = LocationStatus.denied;
        _position = GeoPoint.santiagoCenter;
      }
    } catch (e) {
      _status = LocationStatus.denied;
      _errorMessage = e.toString();
      _position = GeoPoint.santiagoCenter;
    }

    notifyListeners();
  }
}
