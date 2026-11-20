import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HobbyFriend {
  const HobbyFriend({required this.code, required this.addedAt});

  final String code;
  final DateTime addedAt;

  String get label => 'Amigo ${code.substring(code.length - 4)}';
}

class FriendsProvider extends ChangeNotifier {
  FriendsProvider() : _myCode = _generateCode();

  static const _myCodeKey = 'hobbymatch.friend_code.v1';
  static const _friendsKey = 'hobbymatch.friends.v1';

  String _myCode;
  final List<HobbyFriend> _friends = [];

  String get myCode => _myCode;
  String get myQrPayload => 'hobbymatch://friend?code=$_myCode';
  List<HobbyFriend> get friends => List.unmodifiable(_friends);

  Future<void> loadLocalFriends() async {
    final preferences = await SharedPreferences.getInstance();
    _myCode = preferences.getString(_myCodeKey) ?? _myCode;
    await preferences.setString(_myCodeKey, _myCode);

    final savedFriends = preferences.getStringList(_friendsKey) ?? const [];
    _friends
      ..clear()
      ..addAll(savedFriends.map((entry) {
        final separator = entry.indexOf('|');
        final code = separator < 0 ? entry : entry.substring(0, separator);
        final addedAt = separator < 0
            ? DateTime.now()
            : DateTime.tryParse(entry.substring(separator + 1)) ?? DateTime.now();
        return HobbyFriend(code: code, addedAt: addedAt);
      }));
  }

  Future<void> _saveLocalFriends() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_myCodeKey, _myCode);
    await preferences.setStringList(
      _friendsKey,
      _friends.map((friend) => '${friend.code}|${friend.addedAt.toIso8601String()}').toList(),
    );
  }

  static String _generateCode() {
    final random = Random.secure();
    final suffix = List.generate(8, (_) => random.nextInt(36).toRadixString(36)).join().toUpperCase();
    return 'HM-$suffix';
  }

  /// Stores the entered code locally. Resolving a code to a real user requires a backend.
  bool addFriend(String input) {
    final normalized = input.trim().toUpperCase();
    final uri = Uri.tryParse(input.trim());
    final scannedCode = uri?.queryParameters['code']?.trim().toUpperCase();
    final code = scannedCode ?? normalized;
    if (!RegExp(r'^HM-[A-Z0-9]{8}$').hasMatch(code) || code == _myCode) return false;
    if (_friends.any((friend) => friend.code == code)) return false;

    _friends.insert(0, HobbyFriend(code: code, addedAt: DateTime.now()));
    unawaited(_saveLocalFriends());
    notifyListeners();
    return true;
  }

  void removeFriend(String code) {
    _friends.removeWhere((friend) => friend.code == code);
    unawaited(_saveLocalFriends());
    notifyListeners();
  }
}
