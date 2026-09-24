import 'package:flutter/material.dart';

enum EventCategory {
  basketball('Baloncesto', Icons.sports_basketball, Color(0xFFFF6B35)),
  football('Fútbol', Icons.sports_soccer, Color(0xFF2ECC71)),
  meetup('Conocer gente', Icons.groups, Color(0xFF9B59B6)),
  running('Running', Icons.directions_run, Color(0xFF3498DB)),
  gaming('Gaming', Icons.sports_esports, Color(0xFFE74C3C)),
  yoga('Yoga', Icons.self_improvement, Color(0xFF1ABC9C)),
  music('Música', Icons.music_note, Color(0xFFF39C12)),
  boardGames('Juegos de mesa', Icons.casino, Color(0xFF34495E));

  const EventCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
