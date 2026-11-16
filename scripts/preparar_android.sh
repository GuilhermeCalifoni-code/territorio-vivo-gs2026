#!/usr/bin/env bash
set -euo pipefail
command -v flutter >/dev/null || { echo 'Flutter não encontrado no PATH.'; exit 1; }
WORK_DIR="$(pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
flutter create --project-name territorio_vivo --org br.fiap --platforms android --no-pub "$TMP_DIR/tv_flutter_scaffold"
cp "$TMP_DIR/tv_flutter_scaffold/android/gradle/wrapper/gradle-wrapper.jar" "$WORK_DIR/android/gradle/wrapper/gradle-wrapper.jar"
cp "$TMP_DIR/tv_flutter_scaffold/android/gradlew" "$WORK_DIR/android/gradlew"
cp "$TMP_DIR/tv_flutter_scaffold/android/gradlew.bat" "$WORK_DIR/android/gradlew.bat"
chmod +x "$WORK_DIR/android/gradlew"
flutter pub get
flutter analyze
flutter test
echo 'Android preparado. Para executar: flutter run'
echo 'Para APK: flutter build apk --release'
