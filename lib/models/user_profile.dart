import 'dart:convert';
import 'dart:typed_data';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.city,
    required this.bio,
    required this.interests,
    this.avatarBytes,
    this.avatarUrl,
  });

  final String name;
  final String city;
  final String bio;
  final List<String> interests;
  final Uint8List? avatarBytes;
  final String? avatarUrl;

  Map<String, Object?> toJson() => {
        'name': name,
        'city': city,
        'bio': bio,
        'interests': interests,
        if (avatarBytes != null) 'avatarBase64': base64Encode(avatarBytes!),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final encodedAvatar = json['avatarBase64'] as String?;
    return UserProfile(
      name: json['name'] as String? ?? UserProfile.demo.name,
      city: json['city'] as String? ?? UserProfile.demo.city,
      bio: json['bio'] as String? ?? UserProfile.demo.bio,
      interests: (json['interests'] as List<dynamic>?)?.whereType<String>().toList() ?? UserProfile.demo.interests,
      avatarBytes: encodedAvatar == null ? null : base64Decode(encodedAvatar),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  static const demo = UserProfile(
    name: 'Vicente',
    city: 'Santiago, Chile',
    bio: 'Busco gente para jugar y salir. Me encanta el deporte y conocer personas nuevas.',
    interests: ['Baloncesto', 'Fútbol', 'Running', 'Gaming'],
  );
}
