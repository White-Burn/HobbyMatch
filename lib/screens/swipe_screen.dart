import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';

import '../models/hobby_event.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/event_card.dart';
import '../widgets/swipe_action_buttons.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _showMatchSnackBar(HobbyEvent event) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('¡Te interesa "${event.title}"!')),
          ],
        ),
        backgroundColor: AppColors.like,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventsProvider, LocationProvider>(
      builder: (context, provider, location, _) {
        final events = provider.filteredEventsNear(location.position);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              radius: provider.searchRadius,
              locationStatus: location.statusLabel,
              hasGps: location.hasRealLocation,
              onRefreshGps: location.refreshLocation,
              onCreateEvent: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              ),
            ),
            const SizedBox(height: 12),
            CategoryFilterBar(
              selected: provider.selectedCategory,
              onSelected: provider.setCategory,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: events.isEmpty
                  ? _EmptyDeck(onReset: provider.resetDeck)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CardSwiper(
                        controller: _swiperController,
                        cardsCount: events.length,
                        numberOfCardsDisplayed: events.length.clamp(1, 3),
                        backCardOffset: const Offset(0, -28),
                        padding: const EdgeInsets.only(bottom: 24),
                        onSwipe: (previousIndex, currentIndex, direction) {
                          if (previousIndex < 0 || previousIndex >= events.length) {
                            return false;
                          }
                          final event = events[previousIndex];

                          // Updating the provider synchronously can remove the swiper
                          // while its animation listener is still resetting its state.
                          // Defer the deck update until this frame has completed.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            if (direction == CardSwiperDirection.left) {
                              provider.passEvent(event);
                            } else if (direction == CardSwiperDirection.right) {
                              provider.likeEvent(event);
                              _showMatchSnackBar(event);
                            }
                          });
                          return true;
                        },
                        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                          return EventCard(
                            event: events[index],
                            onTap: () => _openDetail(context, events[index]),
                          );
                        },
                      ),
                    ),
            ),
            if (events.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SwipeActionButtons(
                  onPass: () => _swiperController.swipe(CardSwiperDirection.left),
                  onLike: () => _swiperController.swipe(CardSwiperDirection.right),
                  onInfo: () => _openDetail(context, events.first),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openDetail(BuildContext context, HobbyEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.radius,
    required this.locationStatus,
    required this.hasGps,
    required this.onRefreshGps,
    required this.onCreateEvent,
  });

  final String radius;
  final String locationStatus;
  final bool hasGps;
  final VoidCallback onRefreshGps;
  final VoidCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HobbyMatch',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      hasGps ? Icons.gps_fixed : Icons.gps_off,
                      size: 14,
                      color: hasGps ? AppColors.like : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$locationStatus · $radius',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefreshGps,
            icon: const Icon(Icons.my_location),
            tooltip: 'Actualizar GPS',
          ),
          IconButton(
            onPressed: onCreateEvent,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Crear evento',
          ),
        ],
      ),
    );
  }
}

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 72,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'No hay eventos cerca',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Amplía el radio en Perfil, actualiza tu GPS o crea un evento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reiniciar eventos'),
            ),
          ],
        ),
      ),
    );
  }
}
