import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/event_category.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final Set<EventCategory> _selectedHobbies = {};
  Uint8List? _avatarBytes;
  int _currentStep = 0;
  bool _isPickingImage = false;
  bool _isFinishing = false;

  static const _steps = <_StepInfo>[
    _StepInfo(Icons.waving_hand_outlined, '¡Bienvenido a HobbyMatch!', 'Armemos tu perfil para encontrar personas y eventos que conecten con tus hobbies.'),
    _StepInfo(Icons.person_outline, '¿Cómo te llamas?', 'Elige el nombre que verán las demás personas. También puedes agregar tu ciudad.'),
    _StepInfo(Icons.favorite_border, '¿Qué te gusta hacer?', 'Selecciona los hobbies que más te interesan. Puedes elegir varios.'),
    _StepInfo(Icons.photo_camera_outlined, 'Agrega una foto', 'Una foto ayuda a que otras personas te reconozcan.'),
    _StepInfo(Icons.edit_note, 'Cuéntanos sobre ti', 'Escribe una breve descripción para que la comunidad te conozca.'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _pickPhoto() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 800);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (mounted) setState(() => _avatarBytes = bytes);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la galería. Puedes omitir este paso.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _finish() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    final profile = UserProfile(
      name: _nameController.text.trim().isEmpty ? UserProfile.demo.name : _nameController.text.trim(),
      city: _cityController.text.trim().isEmpty ? UserProfile.demo.city : _cityController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? UserProfile.demo.bio : _bioController.text.trim(),
      interests: _selectedHobbies.isEmpty ? UserProfile.demo.interests : _selectedHobbies.map((hobby) => hobby.label).toList(),
      avatarBytes: _avatarBytes,
    );
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('hobbymatch.profile.v1', jsonEncode(profile.toJson()));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar localmente el perfil; continuará esta sesión.')),
        );
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainShell(profile: profile)));
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLastStep = _currentStep == _steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                        _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                      },
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _steps.length,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${_currentStep + 1}/${_steps.length}', style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _isFinishing ? null : _finish, child: const Text('Omitir personalización')),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) => _buildStepContent(index),
                ),
              ),
              Text(step.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(step.subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isFinishing ? null : _currentStep == 0 ? _next : isLastStep ? _finish : _next,
                  child: Text(_currentStep == 0 ? 'Personalizar mi perfil' : isLastStep ? 'Terminar' : 'Continuar'),
                ),
              ),
              TextButton(
                onPressed: _isFinishing ? null : _next,
                child: Text(isLastStep ? 'Omitir y terminar' : 'Omitir este paso'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int index) {
    switch (index) {
      case 0:
        return Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.interests, color: AppColors.primary, size: 72),
          ),
        );
      case 1:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _cityController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Ciudad (opcional)', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder())),
            ],
          ),
        );
      case 2:
        return Center(
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: EventCategory.values.map((hobby) {
                final selected = _selectedHobbies.contains(hobby);
                return FilterChip(
                  avatar: Icon(hobby.icon, size: 18, color: selected ? Colors.white : hobby.color),
                  label: Text(hobby.label),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
                  onSelected: (value) => setState(() {
                    if (value) {
                      _selectedHobbies.add(hobby);
                    } else {
                      _selectedHobbies.remove(hobby);
                    }
                  }),
                );
              }).toList(),
            ),
          ),
        );
      case 3:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 64,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                backgroundImage: _avatarBytes == null ? null : MemoryImage(_avatarBytes!),
                child: _avatarBytes == null ? const Icon(Icons.person, size: 64, color: AppColors.primary) : null,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _isPickingImage ? null : _pickPhoto,
                icon: _isPickingImage ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.photo_library_outlined),
                label: Text(_isPickingImage ? 'Abriendo galería...' : _avatarBytes == null ? 'Elegir de la galería' : 'Cambiar foto'),
              ),
            ],
          ),
        );
      case 4:
        return Center(
          child: TextField(
            controller: _bioController,
            minLines: 3,
            maxLines: 5,
            maxLength: 180,
            decoration: const InputDecoration(hintText: 'Ej.: Me gusta jugar básquetbol y descubrir cafeterías nuevas.', border: OutlineInputBorder()),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepInfo {
  const _StepInfo(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}
