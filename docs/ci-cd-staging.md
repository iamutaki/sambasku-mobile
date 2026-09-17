# CI/CD Staging (Android)

Pola sama seperti `jnn_mobile`: push branch `staging` → analyze/test →
build APK flavor `staging` → GitHub Release.

## Prerequisites

1. **Repo GitHub** untuk mobile (submodule seperti `sambasku-api`), dengan
   workflow di `.github/workflows/deploy-staging.yml` (sudah ada di folder
   `mobile/` ini).
2. **Flavor Android** sudah aktif (`android/app/flavorizr.gradle.kts`).
3. **Keystore** release (satu untuk staging & production):

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
base64 -i upload-keystore.jks | pbcopy   # macOS
```

4. **GitHub Secrets** (Settings → Secrets → Actions):

| Secret | Isi |
| --- | --- |
| `KEYSTORE_BASE64` | output base64 keystore |
| `KEYSTORE_PASSWORD` | store password |
| `KEY_ALIAS` | `upload` (atau alias yang kamu buat) |
| `KEY_PASSWORD` | key password |

## Local release build (opsional)

```bash
cp android/key.properties.example android/key.properties
# edit password + letakkan upload-keystore.jks di android/app/
flutter build apk --release --flavor staging -t lib/main.dart
```

Tanpa `key.properties`, release otomatis pakai debug signing.

## Versioning

- `major.minor` di `pubspec.yaml` diubah manual bila perlu.
- CI mengisi `patch` + `buildNumber` = jumlah commit (`git rev-list --count`).
