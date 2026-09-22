class BugReportImageRef {
  const BugReportImageRef({required this.url, required this.providerFileId});

  final String url;
  final String providerFileId;

  Map<String, dynamic> toJson() => {
    'url': url,
    'provider_file_id': providerFileId,
  };
}

class BugReportSubmitResult {
  const BugReportSubmitResult({
    required this.id,
    required this.status,
    required this.submittedAt,
    required this.isAnonymous,
  });

  final String id;
  final String status;
  final String submittedAt;
  final bool isAnonymous;

  factory BugReportSubmitResult.fromJson(Map<String, dynamic> json) {
    return BugReportSubmitResult(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'open',
      submittedAt: json['submitted_at'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool? ?? true,
    );
  }
}

class UploadCredentials {
  const UploadCredentials({
    required this.token,
    required this.signature,
    required this.expire,
    required this.publicKey,
    required this.uploadEndpoint,
  });

  final String token;
  final String signature;
  final int expire;
  final String publicKey;
  final String uploadEndpoint;

  factory UploadCredentials.fromJson(Map<String, dynamic> json) {
    return UploadCredentials(
      token: json['token'] as String,
      signature: json['signature'] as String,
      expire: json['expire'] as int,
      publicKey: json['public_key'] as String,
      uploadEndpoint: json['upload_endpoint'] as String,
    );
  }
}

class ImageUploadUnavailable implements Exception {
  const ImageUploadUnavailable();
}
