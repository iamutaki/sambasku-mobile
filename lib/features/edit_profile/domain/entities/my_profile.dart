class MyProfile {
  const MyProfile({
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
  });

  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
}
