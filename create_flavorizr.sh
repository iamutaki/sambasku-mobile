#!/bin/bash
set -euo pipefail

# ============================================================
# create_flavorizr.sh (pola jnn_mobile)
# Jalankan flutter_flavorizr untuk generate platform configs
# (Android productFlavors, iOS schemes + bundle id, app name).
# Entry point tetap SATU lib/main.dart (flavor via --dart-define)
# - file main.dart/app.dart di-backup lalu di-restore, dan
# entrypoint generated (main_staging/main_production) dihapus.
# ============================================================

PROJECT_DIR="$(cd "$(dirname "${0}")" && pwd)"
cd "${PROJECT_DIR}"

echo "Running flutter_flavorizr..."

PROTECTED_FILES=(
  "lib/main.dart"
  "lib/app.dart"
  "lib/flavors.dart"
)

echo "Backing up protected files..."
for file in "${PROTECTED_FILES}"; do
  if [[ -f "${file}" ]]; then
    backup="${file}.bck"
    cp "${file}" "${backup}"
    echo "   ok ${file} -> ${backup}"
  fi
done

restore_files() {
  echo "Restoring protected files..."
  for file in "${PROTECTED_FILES}"; do
    backup="${file}.bck"
    if [[ -f "${backup}" ]]; then
      mv "${backup}" "${file}"
      echo "   ok ${backup} -> ${file}"
    fi
  done

  rm -f lib/main_staging.dart
  rm -f lib/main_production.dart
  rm -rf lib/pages

  echo "Done!"
}

trap restore_files EXIT

dart run flutter_flavorizr

echo "Flavorizr completed successfully."
