class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'user-1',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
    );
  }
}
