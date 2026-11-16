# Execute na raiz do projeto, em um PowerShell com o Flutter no PATH.
$ErrorActionPreference = "Stop"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter não encontrado. Instale o SDK estável pelo site oficial e adicione ao PATH."
}
$working = (Get-Location).Path
$tmp = Join-Path $env:TEMP "tv_flutter_scaffold"
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
flutter create --project-name territorio_vivo --org br.fiap --platforms android --no-pub $tmp
if ($LASTEXITCODE -ne 0) { throw "Falha ao gerar scaffold Android." }
$wrapper = Join-Path $tmp "android/gradle/wrapper/gradle-wrapper.jar"
if (-not (Test-Path $wrapper)) { throw "Flutter não gerou gradle-wrapper.jar." }
Copy-Item $wrapper (Join-Path $working "android/gradle/wrapper/gradle-wrapper.jar") -Force
Copy-Item (Join-Path $tmp "android/gradlew") (Join-Path $working "android/gradlew") -Force
Copy-Item (Join-Path $tmp "android/gradlew.bat") (Join-Path $working "android/gradlew.bat") -Force
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "Falha em flutter pub get." }
flutter analyze
if ($LASTEXITCODE -ne 0) { throw "Falha em flutter analyze; corrija os erros antes de prosseguir." }
flutter test
if ($LASTEXITCODE -ne 0) { throw "Falha em flutter test; corrija os testes antes de prosseguir." }
Write-Host "Android preparado. Para testar: flutter run"
Write-Host "Para gerar APK: flutter build apk --release"
