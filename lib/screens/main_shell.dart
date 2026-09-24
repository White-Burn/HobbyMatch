import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/events_provider.dart';
import 'favorites_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'swipe_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    SwipeScreen(),
    MapScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final likedCount = context.watch<EventsProvider>().likedEvents.length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: likedCount > 0,
              label: Text('$likedCount'),
              child: const Icon(Icons.favorite_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: likedCount > 0,
              label: Text('$likedCount'),
              child: const Icon(Icons.favorite),
            ),
            label: 'Mis eventos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
