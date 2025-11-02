# Guia Completo: Certificados Apple para App Store

## 📋 Pré-requisitos
- ✅ Conta Apple Developer ativa ($99/ano)
- ✅ Mac com Xcode instalado
- ✅ Bundle ID: `com.dnotas.app`

## 🔑 PASSO 1: Gerar Certificate Signing Request (CSR)

### No Mac - Keychain Access:
1. Abra **Keychain Access** (Acesso às Chaves)
2. Menu → **Keychain Access** → **Certificate Assistant** → **Request a Certificate From a Certificate Authority...**
3. Preencha:
   - **User Email Address**: seu email da conta developer
   - **Common Name**: DNOTAS App
   - **CA Email Address**: deixe vazio
   - **Request is**: ✅ **Saved to disk**
   - **Let me specify key pair information**: ✅ marque esta opção
4. Clique **Continue**
5. **Key Size**: 2048 bits
6. **Algorithm**: RSA
7. Clique **Continue**
8. Salve como: `DNOTAS_CertificateSigningRequest.certSigningRequest`

**⚠️ IMPORTANTE**: Certifique-se de marcar **"Saved to disk"** e **"Let me specify key pair information"** para gerar corretamente o CSR.

## 🍎 PASSO 2: Apple Developer Center

### 2.1 - Criar App Identifier:
1. Acesse [developer.apple.com](https://developer.apple.com/account)
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → **App IDs** → **+**
4. Configure:
   - **Type**: App
   - **Description**: DNOTAS App
   - **Bundle ID**: Explicit → `com.dnotas.app`
   - **Capabilities**: 
     - ✅ Push Notifications
     - ✅ Background Modes
5. **Continue** → **Register**

### 2.2 - Criar Certificado de Distribuição:
1. **Certificates** → **Production** → **+**
2. Selecione: **Apple Distribution**
3. **Continue**
4. Upload o arquivo CSR criado no Passo 1
5. **Continue**
6. **Download** o certificado (.cer)
7. **Instale** clicando duas vezes (vai para Keychain)

### 2.3 - Criar Provisioning Profile:
1. **Profiles** → **Distribution** → **+**
2. Selecione: **App Store Distribution**
3. **App ID**: Escolha `com.dnotas.app`
4. **Certificate**: Selecione o certificado criado
5. **Profile Name**: `DNOTAS App Store Profile`
6. **Generate** → **Download** (.mobileprovision)

## 🔧 PASSO 3: Configurar Xcode

### 3.1 - Abrir projeto:
```bash
cd APP
open ios/Runner.xcworkspace
```

### 3.2 - Configurar Signing:
1. Selecione projeto **Runner** (topo da lista)
2. Target **Runner**
3. Aba **Signing & Capabilities**
4. Configure:
   - **Team**: Selecione seu team
   - **Bundle Identifier**: `com.dnotas.app`
   - **Provisioning Profile**: Selecione o profile criado
   - **Signing Certificate**: Selecione o certificado

## 📱 PASSO 4: App Store Connect

### 4.1 - Criar App:
1. Acesse [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **Apps** → **+**
3. **New App**:
   - **Name**: DNOTAS App
   - **Primary Language**: Portuguese (Brazil)
   - **Bundle ID**: `com.dnotas.app`
   - **SKU**: `com.dnotas.app`
   - **User Access**: Full Access

### 4.2 - Configurar App:
1. **App Information**:
   - **Category**: Business
   - **Subcategory**: (opcional)
2. **Pricing and Availability**:
   - **Price**: Free
   - **Availability**: All Countries

## 🚀 PASSO 5: Build e Upload

### 5.1 - Gerar IPA:
```bash
flutter clean
flutter pub get
flutter build ipa --release
```

### 5.2 - Upload via Xcode:
1. Xcode → **Window** → **Organizer**
2. **Archives** tab
3. Selecione o build
4. **Distribute App**
5. **App Store Connect**
6. **Upload**

### 5.3 - Alternativa - Transporter:
1. Baixe **Transporter** da Mac App Store
2. Faça login com conta developer
3. Arraste o arquivo `.ipa`
4. **Deliver**

## ⚠️ Problemas Comuns

### Erro: "No signing certificate found"
- Certifique-se que o certificado está instalado no Keychain
- Verifique se o certificado não expirou

### Erro: "Profile doesn't match"
- Bundle ID deve ser exatamente `com.dnotas.app`
- Verifique se o profile está selecionado corretamente

### Erro: "Capability not supported"
- Adicione capabilities no App ID (Push Notifications, etc.)
- Regenere o Provisioning Profile

## 📞 Suporte
- Apple Developer Forums
- Apple Developer Support (pago)
- Documentação oficial da Apple