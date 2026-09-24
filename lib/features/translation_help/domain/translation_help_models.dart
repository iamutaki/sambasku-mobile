// Model domain + wire mapping untuk Bantuan Terjemahan.

class TranslationHelpImageRef {
  const TranslationHelpImageRef({
    required this.url,
    required this.providerFileId,
  });

  final String url;
  final String providerFileId;

  Map<String, dynamic> toJson() => {
    'url': url,
    'provider_file_id': providerFileId,
  };
}

class TranslationHelpUploadCredentials {
  const TranslationHelpUploadCredentials({
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

  factory TranslationHelpUploadCredentials.fromJson(Map<String, dynamic> json) {
    return TranslationHelpUploadCredentials(
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

class TranslationHelpSubmitResult {
  const TranslationHelpSubmitResult({
    required this.id,
    required this.status,
    required this.submittedAt,
  });

  final String id;
  final String status;
  final String submittedAt;

  factory TranslationHelpSubmitResult.fromJson(Map<String, dynamic> json) {
    return TranslationHelpSubmitResult(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'pending_review',
      submittedAt: json['submitted_at'] as String? ?? '',
    );
  }
}

class TranslationHelpImage {
  const TranslationHelpImage({
    this.url,
    this.providerFileId,
    this.publicUrl,
  });

  final String? url;
  final String? providerFileId;
  final String? publicUrl;

  /// URL terbaik untuk tampilan publik (GitHub/jsDelivr → displayImageUrl).
  String? get displaySource {
    final pub = publicUrl?.trim();
    if (pub != null && pub.isNotEmpty) return pub;
    final raw = url?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return null;
  }

  factory TranslationHelpImage.fromJson(Map<String, dynamic> json) {
    return TranslationHelpImage(
      url: json['url']?.toString(),
      providerFileId: json['provider_file_id']?.toString(),
      publicUrl: json['public_url']?.toString(),
    );
  }
}

class TranslationHelpReply {
  const TranslationHelpReply({
    required this.id,
    required this.userId,
    required this.username,
    required this.body,
    required this.status,
    required this.isVerifier,
    required this.isPinned,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? username;
  final String? body;
  final String status;
  final bool isVerifier;
  final bool isPinned;
  final String createdAt;

  bool get isPublished => status == 'published';

  bool isOwner(String? userId) =>
      userId != null && userId.isNotEmpty && userId == this.userId;

  factory TranslationHelpReply.fromJson(Map<String, dynamic> json) {
    return TranslationHelpReply(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString(),
      body: json['body']?.toString(),
      status: json['status']?.toString() ?? 'published',
      isVerifier: json['is_verifier'] == true,
      isPinned: json['is_pinned'] == true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class TranslationHelpItem {
  const TranslationHelpItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.body,
    required this.images,
    required this.status,
    required this.pinnedReplyId,
    required this.createdAt,
    this.rejectionNote,
    this.reviewedAt,
    this.updatedAt,
    this.replies = const [],
  });

  final String id;
  final String userId;
  final String? username;
  final String? body;
  final List<TranslationHelpImage> images;
  final String status;
  final String? pinnedReplyId;
  final String createdAt;
  final String? rejectionNote;
  final String? reviewedAt;
  final String? updatedAt;
  final List<TranslationHelpReply> replies;

  bool get isPublished => status == 'published';

  String get statusLabel => switch (status) {
    'pending_review' => 'Menunggu pengecekan',
    'published' => 'Tayang',
    'rejected' => 'Ditolak',
    'taken_down' => 'Diturunkan',
    _ => status,
  };

  /// Balasan: pinned dulu, lalu sisanya (urut API).
  List<TranslationHelpReply> get orderedReplies {
    if (replies.isEmpty) return const [];
    final pinned = <TranslationHelpReply>[];
    final rest = <TranslationHelpReply>[];
    for (final r in replies) {
      if (r.isPinned) {
        pinned.add(r);
      } else {
        rest.add(r);
      }
    }
    return [...pinned, ...rest];
  }

  List<String> get imageDisplayUrls => [
    for (final img in images)
      if (img.displaySource != null) img.displaySource!,
  ];

  factory TranslationHelpItem.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final repliesRaw = json['replies'];
    return TranslationHelpItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString(),
      body: json['body']?.toString(),
      images: imagesRaw is List
          ? [
              for (final raw in imagesRaw.whereType<Map>())
                TranslationHelpImage.fromJson(Map<String, dynamic>.from(raw)),
            ]
          : const [],
      status: json['status']?.toString() ?? 'published',
      pinnedReplyId: json['pinned_reply_id']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      rejectionNote: json['rejection_note']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      replies: repliesRaw is List
          ? [
              for (final raw in repliesRaw.whereType<Map>())
                TranslationHelpReply.fromJson(Map<String, dynamic>.from(raw)),
            ]
          : const [],
    );
  }

  TranslationHelpItem copyWith({
    List<TranslationHelpReply>? replies,
    String? pinnedReplyId,
  }) {
    return TranslationHelpItem(
      id: id,
      userId: userId,
      username: username,
      body: body,
      images: images,
      status: status,
      pinnedReplyId: pinnedReplyId ?? this.pinnedReplyId,
      createdAt: createdAt,
      rejectionNote: rejectionNote,
      reviewedAt: reviewedAt,
      updatedAt: updatedAt,
      replies: replies ?? this.replies,
    );
  }
}

class TranslationHelpPage {
  const TranslationHelpPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<TranslationHelpItem> items;
  final String? nextCursor;
  final bool hasMore;
}

class TranslationHelpFailure implements Exception {
  const TranslationHelpFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => message;
}
