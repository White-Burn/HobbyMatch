import 'dart:math';

import 'package:flutter/foundation.dart';

class HobbyFriend {
  const HobbyFriend({required this.code, required this.addedAt});

  final String code;
  final DateTime addedAt;

  String get label => 'Amigo ${code.substring(code.length - 4)}';
}

class FriendsProvider extends ChangeNotifier {
  FriendsProvider() : _myCode = _generateCode();

  final String _myCode;
  final List<HobbyFriend> _friends = [];

  String get myCode => _myCode;
  String get myQrPayload => 'hobbymatch://friend?code=$_myCode';
  List<HobbyFriend> get friends => List.unmodifiable(_friends);

  static String _generateCode() {
    final random = Random.secure();
    final suffix = List.generate(8, (_) => random.nextInt(36).toRadixString(36))
        .join()
        .toUpperCase();
    return 'HM-$suffix';
  }

  /// Accepts either a HobbyMatch QR payload or a code typed by the user.
  /// This prototype records the code locally; lookup/sync requires a backend.
  bool addFriend(String input) {
    final normalized = input.trim().toUpperCase();
    final uri = Uri.tryParse(input.trim());
    final scannedCode = uri?.queryParameters['code']?.trim().toUpperCase();
    final code = scannedCode ?? normalized;
    if (!RegExp(r'^HM-[A-Z0-9]{8}$').hasMatch(code) || code == _myCode) {
      return false;
    }
    if (_friends.any((friend) => friend.code == code)) return false;

    _friends.insert(0, HobbyFriend(code: code, addedAt: DateTime.now()));
    notifyListeners();
    return true;
  }
}
