import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/widgets/attachment_images_field.dart';

void main() {
  test('readyAttachmentImages hanya slot siap', () {
    const ready = AttachmentImageSlot(
      id: '1',
      localPath: '/a.jpg',
      uploaded: AttachmentUploadedImage(
        url: 'https://cdn/a.jpg',
        providerFileId: 'file_a',
        isPrimary: true,
      ),
    );
    const uploading = AttachmentImageSlot(
      id: '2',
      localPath: '/b.jpg',
      uploading: true,
    );
    const errored = AttachmentImageSlot(
      id: '3',
      localPath: '/c.jpg',
      error: true,
    );

    final out = readyAttachmentImages([ready, uploading, errored]);
    expect(out, hasLength(1));
    expect(out.single.providerFileId, 'file_a');
    expect(out.single.isPrimary, isTrue);
  });

  test('copyWith clearUploaded menghapus hasil upload', () {
    const slot = AttachmentImageSlot(
      id: '1',
      localPath: '/a.jpg',
      uploaded: AttachmentUploadedImage(
        url: 'https://cdn/a.jpg',
        providerFileId: 'file_a',
      ),
      uploading: true,
    );

    final next = slot.copyWith(
      uploading: false,
      error: true,
      clearUploaded: true,
    );
    expect(next.uploaded, isNull);
    expect(next.uploading, isFalse);
    expect(next.error, isTrue);
    expect(next.isReady, isFalse);
  });

  test('merge base: slot baru tetap ada meski list parent belum rebuild', () {
    // Simulasi _baseForPatch tanpa widget: parent masih kosong, afterAdd
    // sudah punya slot uploading.
    const afterAdd = [
      AttachmentImageSlot(id: 'new', localPath: '/n.jpg', uploading: true),
    ];
    const current = <AttachmentImageSlot>[];

    List<AttachmentImageSlot> baseForPatch(
      String id,
      List<AttachmentImageSlot> currentList,
      List<AttachmentImageSlot> after,
    ) {
      if (currentList.any((e) => e.id == id)) return currentList;
      final seen = {for (final s in currentList) s.id};
      return [
        ...currentList,
        for (final s in after)
          if (!seen.contains(s.id)) s,
      ];
    }

    final base = baseForPatch('new', current, afterAdd);
    expect(base, hasLength(1));
    expect(base.single.id, 'new');

    // Parent sudah rebuild + slot lain: jangan timpa.
    const current2 = [
      AttachmentImageSlot(
        id: 'old',
        localPath: '/o.jpg',
        uploaded: AttachmentUploadedImage(
          url: 'https://cdn/o.jpg',
          providerFileId: 'file_o',
        ),
      ),
      AttachmentImageSlot(id: 'new', localPath: '/n.jpg', uploading: true),
    ];
    final base2 = baseForPatch('new', current2, afterAdd);
    expect(base2.map((e) => e.id), ['old', 'new']);
  });
}
