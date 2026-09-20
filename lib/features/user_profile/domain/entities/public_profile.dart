/// Profil publik by username (19-api-profil-publik.md).
class PublicProfile {
  const PublicProfile({
    required this.username,
    required this.role,
    required this.isVerifier,
    required this.joinedAt,
    required this.contributionsApproved,
    required this.verificationsDone,
  });

  final String username;
  final String role;
  final bool isVerifier;
  final String joinedAt;
  final int contributionsApproved;
  final int verificationsDone;
}
