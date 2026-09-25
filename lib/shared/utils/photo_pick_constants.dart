/// Batas kompresi foto lewat [ImagePicker] (mobile-base-stack §9.2).
///
/// Tidak ada sisi melebihi 720; aspect ratio tetap. Quality JPEG 80.
const double kPhotoPickMaxWidth = 720;
const double kPhotoPickMaxHeight = 720;
const int kPhotoPickQuality = 80;

/// Batas pick sumber untuk avatar (sebelum crop). Lebih longgar supaya
/// crop 1:1 tetap tajam; export akhir tetap [kPhotoPickMaxWidth].
const double kAvatarPickMaxWidth = 1600;
const double kAvatarPickMaxHeight = 1600;
