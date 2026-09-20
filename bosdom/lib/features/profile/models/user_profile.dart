class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.role,
    required this.email,
    this.avatarUrl = '',
    this.verificationStatus = 'unverified',
    this.onboardingComplete = false,
    this.verificationUpdatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String,
    phone: json['phone'] as String,
    role: json['role'] as String,
    email: json['email'] as String,
    avatarUrl: json['avatar_url'] as String? ?? '',
    verificationStatus: json['verification_status'] as String? ?? 'unverified',
    onboardingComplete: json['onboarding_complete'] as bool? ?? false,
    verificationUpdatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );

  final String name;
  final String phone;
  final String role;
  final String email;
  final String avatarUrl;

  // One of "unverified", "pending", "verified", "rejected" — see the
  // backend's admin.py/profile.py for the KYC review state machine.
  final String verificationStatus;

  // True only once the user has finished every step of the signup wizard —
  // NOT just once an account/profile row exists. `role` gets set as early
  // as the personal-details step, so it can't be used to tell "mid-wizard"
  // apart from "fully onboarded" (see ProfileService.completeOnboarding).
  final bool onboardingComplete;

  // When `verificationStatus` last changed, e.g. when KYC docs were
  // submitted or an admin reviewed them — lets the UI show "Submitted on…".
  final DateTime? verificationUpdatedAt;

  bool get isVerifiedSeller => verificationStatus == 'verified';

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
    String? verificationStatus,
    bool? onboardingComplete,
    DateTime? verificationUpdatedAt,
  }) => UserProfile(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    verificationUpdatedAt: verificationUpdatedAt ?? this.verificationUpdatedAt,
  );
}
