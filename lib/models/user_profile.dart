class UserProfile {
  const UserProfile({
    required this.name,
    required this.city,
    required this.bio,
    required this.interests,
    this.avatarUrl,
  });

  final String name;
  final String city;
  final String bio;
  final List<String> interests;
  final String? avatarUrl;

  static const demo = UserProfile(
    name: 'Vicente',
    city: 'Santiago, Chile',
    bio: 'Busco gente para jugar y salir. Me encanta el deporte y conocer personas nuevas.',
    interests: ['Baloncesto', 'Fútbol', 'Running', 'Gaming'],
  );
}
