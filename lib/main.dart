import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_profile.dart';
import 'providers/events_provider.dart';
import 'providers/friends_provider.dart';
import 'providers/location_provider.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  final eventsProvider = EventsProvider();
  final friendsProvider = FriendsProvider();
  await Future.wait([
    eventsProvider.loadLocalEvents(),
    friendsProvider.loadLocalFriends(),
  ]);

  final preferences = await SharedPreferences.getInstance();
  final encodedProfile = preferences.getString('hobbymatch.profile.v1');
  UserProfile? savedProfile;
  if (encodedProfile != null) {
    try {
      savedProfile = UserProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(encodedProfile) as Map),
      );
    } on FormatException {
      await preferences.remove('hobbymatch.profile.v1');
    } on TypeError {
      await preferences.remove('hobbymatch.profile.v1');
    }
  }

  runApp(HobbyMatchApp(
    eventsProvider: eventsProvider,
    friendsProvider: friendsProvider,
    savedProfile: savedProfile,
  ));
}

class HobbyMatchApp extends StatelessWidget {
  const HobbyMatchApp({
    super.key,
    required this.eventsProvider,
    required this.friendsProvider,
    this.savedProfile,
  });

  final EventsProvider eventsProvider;
  final FriendsProvider friendsProvider;
  final UserProfile? savedProfile;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()..initialize()),
        ChangeNotifierProvider<EventsProvider>.value(value: eventsProvider),
        ChangeNotifierProvider<FriendsProvider>.value(value: friendsProvider),
      ],
      child: MaterialApp(
        title: 'HobbyMatch',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: savedProfile == null
            ? const OnboardingScreen()
            : MainShell(profile: savedProfile!),
      ),
    );
  }
}
