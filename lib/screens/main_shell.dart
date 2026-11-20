import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';
import 'favorites_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'swipe_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.profile = UserProfile.demo});

  final UserProfile profile;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final likedCount = context.watch<EventsProvider>().likedEvents.length;
    final screens = [
      const SwipeScreen(),
      const MapScreen(),
      const FavoritesScreen(),
      ProfileScreen(profile: widget.profile),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explorar'),
          const NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(
            icon: Badge(isLabelVisible: likedCount > 0, label: Text('$likedCount'), child: const Icon(Icons.favorite_outline)),
            selectedIcon: Badge(isLabelVisible: likedCount > 0, label: Text('$likedCount'), child: const Icon(Icons.favorite)),
            label: 'Mis eventos',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
