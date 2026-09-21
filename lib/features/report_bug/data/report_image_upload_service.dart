import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../contribution/data/datasources/imagekit_uploader.dart';
import '../../contribution/data/models/upload_credentials_dto.dart';
import '../domain/bug_report_models.dart';
import 'bug_report_repository.dart';

/// Token publik `/bug-reports` → upload CDN. Reuse ImageKitUploader kontribusi.
class ReportImageUploadService {
  ReportImageUploadService(this._repo, {ImageKitUploader? uploader})
    : _uploader = uploader ?? ImageKitUploader();

  final BugReportRepository _repo;
  final ImageKitUploader _uploader;

  Future<BugReportImageRef> upload(XFile file) async {
    final creds = await _repo.getUploadToken();
    final uploaded = await _uploader.upload(
      file: File(file.path),
      creds: UploadCredentialsDto(
        token: creds.token,
        signature: creds.signature,
        expire: creds.expire,
        publicKey: creds.publicKey,
        uploadEndpoint: creds.uploadEndpoint,
      ),
      folder: '/bug-reports',
    );
    return BugReportImageRef(url: uploaded.url, providerFileId: uploaded.fileId);
  }
}
