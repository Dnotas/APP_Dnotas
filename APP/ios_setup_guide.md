# Guia de Configuração iOS para App Store

## Pré-requisitos
- Conta Apple Developer ativa
- Xcode instalado
- Bundle ID: `com.dnotas.app`

## Passos no Apple Developer Center

### 1. Criar App Identifier
1. Acesse [developer.apple.com](https://developer.apple.com)
2. Vá em Certificates, Identifiers & Profiles
3. Clique em Identifiers → App IDs
4. Clique no "+" para criar novo
5. Configure:
   - Type: App
   - Bundle ID: `com.dnotas.app`
   - Description: DNOTAS App
   - Capabilities: Push Notifications, Background Modes

### 2. Criar Certificados de Distribuição
1. Vá em Certificates → Production
2. Clique no "+" 
3. Selecione "Apple Distribution"
4. Faça upload do CSR (Certificate Signing Request)
5. Baixe o certificado (.cer)
6. Instale no Keychain

### 3. Criar Provisioning Profile
1. Vá em Profiles → Distribution
2. Clique no "+"
3. Selecione "App Store Distribution"
4. Escolha o App ID: `com.dnotas.app`
5. Selecione o certificado de distribuição
6. Baixe o profile (.mobileprovision)

### 4. Configurar no Xcode
1. Abra o projeto iOS no Xcode:
   ```
   open ios/Runner.xcworkspace
   ```
2. Selecione o target "Runner"
3. Na aba "Signing & Capabilities":
   - Team: Selecione seu time
   - Bundle Identifier: `com.dnotas.app`
   - Provisioning Profile: Selecione o profile criado

### 5. Criar App no App Store Connect
1. Acesse [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Clique em "Apps" → "+"
3. Configure:
   - Name: DNOTAS App
   - Bundle ID: `com.dnotas.app`
   - Language: Portuguese (Brazil)
   - SKU: com.dnotas.app

## Comandos para Build

### Testar build local:
```bash
cd APP
flutter build ios --release
```

### Fazer upload para App Store:
```bash
cd APP
flutter build ipa --release
```

O arquivo .ipa será gerado em: `build/ios/ipa/dnotas_app.ipa`

Upload via Xcode Organizer ou Application Loader.