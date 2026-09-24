import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/hobby_event.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';
import 'event_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        final liked = provider.likedEvents;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('Mis eventos'),
              actions: [
                if (liked.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmClear(context, provider),
                    child: const Text('Limpiar'),
                  ),
              ],
            ),
            if (liked.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyFavorites(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
                  itemCount: liked.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = liked[index];
                    return _FavoriteTile(
                      event: event,
                      onTap: () => _openDetail(context, event),
                      onRemove: () => provider.removeFromLiked(event),
                    );
                  },
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

  void _confirmClear(BuildContext context, EventsProvider provider) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Limpiar favoritos?'),
        content: const Text('Se quitarán todos los eventos guardados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              for (final event in List.of(provider.likedEvents)) {
                provider.removeFromLiked(event);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.event,
    required this.onTap,
    required this.onRemove,
  });

  final HobbyEvent event;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("d MMM · HH:mm", 'es');
    final events = context.watch<EventsProvider>();
    final user = context.watch<LocationProvider>().position;
    final venue = events.venueFor(event);
    final distance = events.eventDistanceLabel(event, user);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: event.category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(event.category.icon, color: event.category.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(event.dateTime)} · $distance · ${venue.shortAddress}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.close, color: AppColors.textSecondary.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppColors.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes eventos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Desliza a la derecha en eventos que te interesen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
