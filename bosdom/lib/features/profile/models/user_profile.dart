class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.role,
    required this.email,
    this.avatarUrl = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String,
    phone: json['phone'] as String,
    role: json['role'] as String,
    email: json['email'] as String,
    avatarUrl: json['avatar_url'] as String? ?? '',
  );

  final String name;
  final String phone;
  final String role;
  final String email;
  final String avatarUrl;

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'role': role,
    'email': email,
  };

  UserProfile copyWith({
    String? name,
    String? phone,
    String? role,
    String? email,
    String? avatarUrl,
  }) => UserProfile(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );
}
