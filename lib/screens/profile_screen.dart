import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.profile = UserProfile.demo});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventsProvider, LocationProvider>(
      builder: (context, provider, location, _) {
        return CustomScrollView(
          slivers: [
            const SliverAppBar(floating: true, title: Text('Mi perfil')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      backgroundImage: profile.avatarBytes != null ? MemoryImage(profile.avatarBytes!) : null,
                      child: profile.avatarBytes == null
                          ? Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary))
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(profile.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(profile.city, style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(profile.bio, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                    const SizedBox(height: 24),
                    _StatsRow(liked: provider.likedEvents.length, passed: provider.passedEvents.length),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Mis hobbies'),
                    const SizedBox(height: 10),
                    if (profile.interests.isEmpty)
                      const Text('Aún no agregas hobbies.', style: TextStyle(color: AppColors.textSecondary))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: profile.interests.map((interest) => Chip(
                          label: Text(interest),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                          side: BorderSide.none,
                        )).toList(),
                      ),
                    const SizedBox(height: 32),
                    const _SectionTitle(title: 'Configuración'),
                    const SizedBox(height: 8),
                    _SettingsTile(icon: Icons.gps_fixed, title: 'Ubicación GPS', subtitle: location.statusLabel, onTap: location.refreshLocation),
                    _SettingsTile(icon: Icons.location_on_outlined, title: 'Radio de búsqueda', subtitle: provider.searchRadius, onTap: () => _showRadiusPicker(context, provider)),
                    const _SettingsTile(icon: Icons.notifications_outlined, title: 'Notificaciones', subtitle: 'Activadas', onTap: _noop),
                    _SettingsTile(icon: Icons.refresh, title: 'Reiniciar eventos', subtitle: 'Volver a ver todos los eventos', onTap: () => _confirmReset(context, provider)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _noop() {}

  void _showRadiusPicker(BuildContext context, EventsProvider provider) {
    const options = ['2 km', '5 km', '10 km', '25 km'];
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Radio de búsqueda', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
            ...options.map((option) => ListTile(
              title: Text(option),
              trailing: provider.searchRadius == option ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                provider.setSearchRadius(option);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, EventsProvider provider) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Reiniciar eventos?'),
        content: const Text('Volverás a ver todos los eventos desde el inicio. Tus favoritos se borrarán. Tus eventos creados permanecerán en “Mis eventos”.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () { provider.resetDeck(); Navigator.pop(ctx); }, child: const Text('Reiniciar')),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.liked, required this.passed});
  final int liked;
  final int passed;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: _StatCard(label: 'Interesados', value: liked, color: AppColors.like)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(label: 'Descartados', value: passed, color: AppColors.pass)),
    ],
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
    child: Column(
      children: [
        Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    contentPadding: EdgeInsets.zero,
  );
}
