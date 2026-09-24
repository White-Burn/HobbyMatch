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
  const CreateEventScreen({super.key, this.preselectedVenueId});

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
  bool _isSubmitting = false;

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
      initialDate: _dateTime.isBefore(DateTime.now()) ? DateTime.now() : _dateTime,
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
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    final venue = _selectedVenueId == null ? null : venueById(_selectedVenueId!);
    if (venue == null) {
      _showError('Selecciona un espacio para el evento.');
      return;
    }
    if (!_dateTime.isAfter(DateTime.now())) {
      _showError('La fecha y hora deben ser futuras.');
      return;
    }
    if (_maxParticipants > venue.capacity) {
      _showError('Este espacio tiene capacidad para ${venue.capacity} personas.');
      return;
    }

    setState(() => _isSubmitting = true);
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .take(8)
        .toList();

    final event = context.read<EventsProvider>().createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          dateTime: _dateTime,
          venueId: venue.id,
          maxParticipants: _maxParticipants,
          tags: tags,
        );

    if (!mounted) return;
    Navigator.of(context).pop(event);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LocationProvider>().position;
    final events = context.watch<EventsProvider>();
    final selectedVenue = _selectedVenueId == null ? null : venueById(_selectedVenueId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear evento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (selectedVenue != null)
              EventMapWidget(
                center: GeoPoint(latitude: selectedVenue.latitude, longitude: selectedVenue.longitude),
                userPosition: user,
                venues: [selectedVenue],
                selectedVenueId: selectedVenue.id,
                height: 180,
                events: const [],
              ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Título del evento',
                hintText: 'Ej: Partido 3x3 viernes',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Ingresa un título';
                if (text.length < 5) return 'Usa al menos 5 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Nivel, qué traer, ambiente...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Ingresa una descripción';
                if (text.length < 10) return 'Agrega un poco más de información';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
              items: EventCategory.values.map((category) => DropdownMenuItem(
                    value: category,
                    child: Row(children: [
                      Icon(category.icon, color: category.color, size: 20),
                      const SizedBox(width: 8),
                      Text(category.label),
                    ]),
                  )).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha y hora'),
              subtitle: Text(DateFormat('EEE d MMM yyyy · HH:mm', 'es').format(_dateTime)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Cupos máximos'),
                const Spacer(),
                IconButton(
                  onPressed: _maxParticipants > 2 ? () => setState(() => _maxParticipants--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_maxParticipants', style: const TextStyle(fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: selectedVenue != null && _maxParticipants < selectedVenue.capacity
                      ? () => setState(() => _maxParticipants++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            VenuePicker(
              selectedVenueId: _selectedVenueId,
              onSelected: (venue) {
                setState(() {
                  _selectedVenueId = venue.id;
                  if (_maxParticipants > venue.capacity) _maxParticipants = venue.capacity;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Etiquetas (opcional)',
                hintText: 'Gratis, Principiantes, Semanal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_isSubmitting ? 'Publicando...' : 'Publicar evento'),
            ),
          ],
        ),
      ),
    );
  }
}
