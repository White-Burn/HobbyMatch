import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/friends_provider.dart';
import '../theme/app_theme.dart';
import 'friend_qr_scanner_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _addCode(FriendsProvider provider, String code) {
    final added = provider.addFriend(code);
    if (added) _codeController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added
            ? 'Código agregado a tus amistades.'
            : 'Código inválido, propio o ya agregado.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _scanCode(FriendsProvider provider) async {
    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const FriendQrScannerScreen()),
    );
    if (!mounted || scanned == null) return;
    _addCode(provider, scanned);
  }

  @override
  Widget build(BuildContext context) {
    final friendsProvider = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Amistades')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 42, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text('Tu código de amistad', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Compártelo para que puedan agregarte.', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: SelectableText(friendsProvider.myCode, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  QrImageView(data: friendsProvider.myQrPayload, size: 190),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Agregar una amistad', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Código de amistad',
              hintText: 'HM-XXXXXXXX',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Agregar código',
                onPressed: () => _addCode(friendsProvider, _codeController.text),
                icon: const Icon(Icons.person_add_alt_1),
              ),
            ),
            onSubmitted: (value) => _addCode(friendsProvider, value),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _scanCode(friendsProvider),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Escanear QR'),
          ),
          const SizedBox(height: 24),
          Text('Mis amistades (${friendsProvider.friends.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (friendsProvider.friends.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('Todavía no agregas amistades. Comparte tu QR o ingresa un código.', textAlign: TextAlign.center),
              ),
            )
          else
            ...friendsProvider.friends.map((friend) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(friend.label),
                subtitle: SelectableText(friend.code),
                trailing: IconButton(
                  tooltip: 'Quitar amistad',
                  icon: const Icon(Icons.close),
                  onPressed: () => friendsProvider.removeFriend(friend.code),
                ),
              ),
            )),
          const SizedBox(height: 16),
          const Text(
            'La lista y los códigos son un prototipo local. Para encontrar perfiles reales y sincronizar amistades entre teléfonos se necesita un backend.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
