import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/predefined_venues.dart';
import '../models/event_category.dart';
import '../models/geo_point.dart';
import '../providers/events_provider.dart';
import '../providers/location_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/event_map_widget.dart';
import '../widgets/venue_picker.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({
    super.key,
    this.preselectedVenueId,
  });

  final String? preselectedVenueId;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  EventCategory _category = EventCategory.basketball;
  String? _selectedVenueId;
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));
  int _maxParticipants = 12;

  @override
  void initState() {
    super.initState();
    _selectedVenueId = widget.preselectedVenueId ?? predefinedVenues.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedVenueId == null) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final event = context.read<EventsProvider>().createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          dateTime: _dateTime,
          venueId: _selectedVenueId!,
          maxParticipants: _maxParticipants,
          tags: tags,
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Evento "${event.title}" creado'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.like,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LocationProvider>().position;
    final events = context.watch<EventsProvider>();
    final selectedVenue = _selectedVenueId != null
        ? events.venues.where((v) => v.id == _selectedVenueId).firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear evento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (selectedVenue != null)
              EventMapWidget(
                center: GeoPoint(
                  latitude: selectedVenue.latitude,
                  longitude: selectedVenue.longitude,
                ),
                userPosition: user,
                venues: [selectedVenue],
                selectedVenueId: selectedVenue.id,
                height: 180,
                events: const [],
              ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del evento',
                hintText: 'Ej: Partido 3x3 viernes',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa un título' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Nivel, qué traer, ambiente...',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa una descripción' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: EventCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon, color: c.color, size: 20),
                          const SizedBox(width: 8),
                          Text(c.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha y hora'),
              subtitle: Text(DateFormat("EEE d MMM yyyy · HH:mm", 'es').format(_dateTime)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Cupos máximos'),
                const Spacer(),
                IconButton(
                  onPressed: _maxParticipants > 2
                      ? () => setState(() => _maxParticipants--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_maxParticipants', style: const TextStyle(fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: () => setState(() => _maxParticipants++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            VenuePicker(
              selectedVenueId: _selectedVenueId,
              onSelected: (venue) => setState(() => _selectedVenueId = venue.id),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Etiquetas (opcional)',
                hintText: 'Gratis, Principiantes, Semanal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('Publicar evento'),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
