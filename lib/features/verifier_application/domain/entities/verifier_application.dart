class SocialLink {
  const SocialLink({required this.platform, required this.url});

  final String platform;
  final String url;
}

class VerifierApplication {
  const VerifierApplication({
    required this.id,
    required this.status,
    required this.phone,
    required this.address,
    required this.socialLinks,
    this.adminComment,
    this.reviewedAt,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String status;
  final String phone;
  final String address;
  final List<SocialLink> socialLinks;
  final String? adminComment;
  final String? reviewedAt;
  final String createdAt;
  final String? updatedAt;

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isApproved => status == 'approved';
}
