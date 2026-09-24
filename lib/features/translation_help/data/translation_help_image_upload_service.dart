import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../contribution/data/datasources/imagekit_uploader.dart';
import '../../contribution/data/models/upload_credentials_dto.dart';
import '../domain/translation_help_models.dart';
import 'translation_help_repository.dart';

/// Token `/translation-helps` → upload CDN. Reuse ImageKitUploader kontribusi.
class TranslationHelpImageUploadService {
  TranslationHelpImageUploadService(this._repo, {ImageKitUploader? uploader})
    : _uploader = uploader ?? ImageKitUploader();

  final TranslationHelpRepository _repo;
  final ImageKitUploader _uploader;

  Future<TranslationHelpImageRef> upload(File file) async {
    final creds = await _repo.getUploadToken();
    final uploaded = await _uploader.upload(
      file: file,
      creds: UploadCredentialsDto(
        token: creds.token,
        signature: creds.signature,
        expire: creds.expire,
        publicKey: creds.publicKey,
        uploadEndpoint: creds.uploadEndpoint,
      ),
      folder: '/translation-helps',
    );
    return TranslationHelpImageRef(
      url: uploaded.url,
      providerFileId: uploaded.fileId,
    );
  }

  Future<TranslationHelpImageRef> uploadXFile(XFile file) =>
      upload(File(file.path));
}
