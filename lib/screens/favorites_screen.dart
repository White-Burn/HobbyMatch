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
        final attending = provider.likedEvents;
        final created = provider.userCreatedEvents;
        final hasEvents = attending.isNotEmpty || created.isNotEmpty;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('Mis eventos'),
              actions: [
                if (attending.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmClear(context, provider),
                    child: const Text('Limpiar favoritos'),
                  ),
              ],
            ),
            if (!hasEvents)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyEvents(),
              )
            else ...[
              if (attending.isNotEmpty) ...[
                const SliverToBoxAdapter(child: _SectionHeading(title: 'Quiero asistir')),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList.separated(
                    itemCount: attending.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = attending[index];
                      return _EventTile(
                        event: event,
                        onTap: () => _openDetail(context, event),
                        onRemove: () => provider.removeFromLiked(event),
                      );
                    },
                  ),
                ),
              ],
              if (created.isNotEmpty) ...[
                const SliverToBoxAdapter(child: _SectionHeading(title: 'Organizados por mí')),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: created.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = created[index];
                      return _EventTile(
                        event: event,
                        onTap: () => _openDetail(context, event),
                        isCreated: true,
                      );
                    },
                  ),
                ),
              ],
            ],
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
        content: const Text('Se quitarán los eventos que marcaste para asistir. Tus eventos creados no se borrarán.'),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      );
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onTap, this.onRemove, this.isCreated = false});

  final HobbyEvent event;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool isCreated;

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
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(event.dateTime)} · $distance · ${venue.shortAddress}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    if (isCreated) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Organizado por ti · Tú incluido: ${event.currentParticipants}/${event.maxParticipants} asistentes',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Quitar de mis eventos',
                  icon: Icon(Icons.close, color: AppColors.textSecondary.withOpacity(0.6)),
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note_outlined, size: 64, color: AppColors.primary.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                'Aún no tienes eventos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Los eventos que marques para asistir y los que organices aparecerán aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
}
