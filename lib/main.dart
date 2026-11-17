import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/events_provider.dart';
import 'providers/location_provider.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const HobbyMatchApp());
}

class HobbyMatchApp extends StatelessWidget {
  const HobbyMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
      ],
      child: MaterialApp(
        title: 'HobbyMatch',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('es'),
        supportedLocales: const [
          Locale('es'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const OnboardingScreen(),
      ),
    );
  }
}
