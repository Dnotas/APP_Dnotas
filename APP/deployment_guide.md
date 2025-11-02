# Guia de Deploy DNOTAS App

## ✅ Android - Google Play Store (PRONTO)

### Arquivos Configurados:
- ✅ Keystore gerada: `upload-keystore.jks`
- ✅ Chave de assinatura configurada: `android/key.properties`
- ✅ Build.gradle atualizado para release
- ✅ AAB gerado: `build/app/outputs/bundle/release/app-release.aab (25.1MB)`

### Credenciais da Keystore:
- **Arquivo**: `upload-keystore.jks`
- **Alias**: `upload`
- **Senha Store**: `dnotas2024`
- **Senha Key**: `dnotas2024`

⚠️ **IMPORTANTE**: Guarde essas credenciais em local seguro! Sem elas você não conseguirá atualizar o app.

### Upload para Google Play:
1. Acesse [Google Play Console](https://play.google.com/console)
2. Vá no seu app ou crie um novo
3. Em "Release" → "Production"
4. Faça upload do arquivo: `build/app/outputs/bundle/release/app-release.aab`
5. Preencha as informações solicitadas
6. Publique!

## 📱 iOS - App Store (CONFIGURAÇÃO MANUAL NECESSÁRIA)

### O que foi preparado:
- ✅ Projeto Flutter configurado
- ✅ Bundle ID: `com.dnotas.app`
- ✅ Info.plist configurado
- ✅ Guia criado: `ios_setup_guide.md`

### Próximos passos (MANUAL):
1. Configure certificados no Apple Developer Center
2. Abra o projeto no Xcode: `open ios/Runner.xcworkspace`
3. Configure Team e Provisioning Profile
4. Execute: `flutter build ipa --release`
5. Upload via Xcode Organizer

## 🚀 Comandos Rápidos

### Rebuild Android:
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### Rebuild iOS (após configurar certificados):
```bash
flutter clean
flutter pub get
flutter build ipa --release
```

## 📋 Checklist Final

### Android:
- [x] Keystore configurada
- [x] Build.gradle atualizado
- [x] AAB gerado com sucesso
- [x] Pronto para upload!

### iOS:
- [x] Projeto configurado
- [ ] Certificados Apple (FAZER MANUAL)
- [ ] Provisioning Profile (FAZER MANUAL)
- [ ] IPA gerado (APÓS CERTIFICADOS)

## 🔧 Informações Técnicas

- **App ID**: `com.dnotas.app`
- **Versão**: `1.0.0+1`
- **Min SDK Android**: 21
- **Target SDK Android**: 35
- **iOS Deployment Target**: 11.0