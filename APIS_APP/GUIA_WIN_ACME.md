# Guia Completo: Configurar HTTPS com win-acme para API DNOTAS

## O que foi configurado

A API DNOTAS agora está configurada para rodar com HTTPS na **porta 9999** usando certificados SSL gerados pelo win-acme (Let's Encrypt).

---

## Pré-requisitos

1. ✅ Servidor Windows com acesso administrativo
2. ✅ Domínio `api.dnotas.com.br` apontando para o IP do servidor
3. ✅ Porta 9999 liberada no firewall do servidor
4. ✅ win-acme instalado em `C:\win-acme`

---

## Passo 1: Baixar e Instalar win-acme

1. Baixe o win-acme em: https://www.win-acme.com/
2. Extraia para `C:\win-acme`
3. Execute como Administrador

---

## Passo 2: Criar as pastas necessárias

Abra o PowerShell como Administrador e execute:

```powershell
# Criar pasta para certificados
New-Item -ItemType Directory -Force -Path "C:\CERTIFICADOS"

# Criar pasta para validação HTTP
New-Item -ItemType Directory -Force -Path "C:\CERTIFICADOS_VALIDACAO"
```

---

## Passo 3: Gerar certificado com win-acme

Abra o PowerShell/CMD como Administrador na pasta do win-acme:

```cmd
cd C:\win-acme
wacs.exe
```

### Siga as escolhas abaixo:

#### 1. Menu Principal
- Digite: **M** (Full options)

#### 2. Como determinar os domínios?
- Digite: **2** (Manual input)
- Digite o domínio: `api.dnotas.com.br`

#### 3. Dividir certificados?
- Digite: **4** (Single certificate)

#### 4. Método de validação?
- Digite: **2** (http-01 Save verification files on memory)
- **IMPORTANTE**: Este método requer que você tenha um servidor web rodando na porta 80 para validação

**ALTERNATIVA (SE NÃO TIVER WEB NA PORTA 80):**
- Digite: **1** (http-01 Self-host verification server)
- Isso criará um servidor temporário para validação

#### 5. Pasta para salvar os arquivos de validação HTTP?
```
C:\CERTIFICADOS_VALIDACAO
```

#### 6. Tipo de chave privada?
- Digite: **2** (RSA key)

#### 7. Onde armazenar o certificado?
- Digite: **2** (PEM encoded files)

#### 8. Pasta para salvar os arquivos .pem?
```
C:\CERTIFICADOS
```

#### 9. Senha na chave privada?
- Digite: **1** (None)

#### 10. Salvar de outra forma?
- Digite: **5** (No additional store steps)

#### 11. Passos adicionais?
- Digite: **3** (No additional installation steps)

---

## Passo 4: Verificar os certificados gerados

Após a conclusão, verifique se os seguintes arquivos foram criados em `C:\CERTIFICADOS`:

```
C:\CERTIFICADOS\
├── api.dnotas.com.br-key.pem     (Chave privada)
├── api.dnotas.com.br-crt.pem     (Certificado)
└── api.dnotas.com.br-chain.pem   (Cadeia de certificação)
```

---

## Passo 5: Iniciar a API DNOTAS

### Opção 1: Modo Desenvolvimento (com auto-reload)

```cmd
cd C:\ERP_SISTEMAS\APP_Dnotas\APIS_APP
npm run dev
```

### Opção 2: Modo Produção

```cmd
cd C:\ERP_SISTEMAS\APP_Dnotas\APIS_APP
npm start
```

---

## Passo 6: Testar o HTTPS

Abra o navegador e acesse:

```
https://api.dnotas.com.br:9999
```

Ou teste via PowerShell:

```powershell
Invoke-WebRequest -Uri "https://api.dnotas.com.br:9999" -UseBasicParsing
```

Resposta esperada:
```json
{
  "message": "API DNOTAS - Vendas do Dia",
  "status": "online",
  "timestamp": "2025-XX-XXTXX:XX:XX.XXXZ"
}
```

---

## Renovação Automática

O win-acme configura uma **tarefa agendada** no Windows para renovar automaticamente os certificados a cada 60 dias.

Para verificar:
1. Abra o **Agendador de Tarefas** do Windows
2. Procure por: `win-acme renew (ACME-Server)`

---

## Troubleshooting

### Erro: "Porta já está em uso"

```powershell
# Ver qual processo está usando a porta 9999
netstat -ano | findstr :9999

# Matar o processo (substitua PID pelo número retornado)
taskkill /PID <PID> /F
```

### Erro: "Certificado não encontrado"

Verifique se o caminho está correto no arquivo `server.js` (linha 13):

```javascript
const certPath = 'C:/CERTIFICADOS';
```

### Erro: "ENOENT: no such file or directory"

Certifique-se de que os arquivos .pem existem:

```cmd
dir C:\CERTIFICADOS
```

### Erro na validação HTTP do win-acme

Se a validação falhar, verifique:
1. O domínio `api.dnotas.com.br` está apontando para o IP correto?
2. A porta 80 está liberada no firewall?
3. Há outro serviço usando a porta 80?

---

## Configuração do Firewall Windows

Liberar a porta 9999:

```powershell
# Abrir PowerShell como Administrador

# Regra de entrada (HTTPS API DNOTAS)
New-NetFirewallRule -DisplayName "API DNOTAS HTTPS" -Direction Inbound -LocalPort 9999 -Protocol TCP -Action Allow

# Verificar
Get-NetFirewallRule -DisplayName "API DNOTAS HTTPS"
```

---

## Configuração para Produção

### Criar um serviço Windows para rodar a API

1. Instale o PM2 globalmente:

```cmd
npm install -g pm2
npm install -g pm2-windows-service
```

2. Configure o serviço:

```cmd
cd C:\ERP_SISTEMAS\APP_Dnotas\APIS_APP
pm2 start src/server.js --name "api-dnotas"
pm2 save
pm2-service-install
```

3. Gerenciar o serviço:

```cmd
# Iniciar
pm2 start api-dnotas

# Parar
pm2 stop api-dnotas

# Reiniciar
pm2 restart api-dnotas

# Ver logs
pm2 logs api-dnotas

# Ver status
pm2 status
```

---

## URLs da API

Depois de configurado, sua API estará disponível em:

- **Base URL**: `https://api.dnotas.com.br:9999`
- **Registro de Vendas**: `POST https://api.dnotas.com.br:9999/vendas_hoje`
- **Consulta de Vendas**: `GET https://api.dnotas.com.br:9999/api/relatorios/vendas/:cnpj`

---

## IMPORTANTE: Configuração no APP Flutter

No seu APP Flutter, atualize a URL base para:

```dart
// Em algum arquivo de configuração
const String API_BASE_URL = 'https://api.dnotas.com.br:9999';
```

**NOTA**: Como você vai passar a URL diretamente no APP, os usuários não precisam digitar a porta manualmente!

---

## Checklist Final

- [ ] win-acme instalado e certificados gerados
- [ ] Pasta `C:\CERTIFICADOS` existe com os 3 arquivos .pem
- [ ] Porta 9999 liberada no firewall
- [ ] API rodando com `npm start` ou PM2
- [ ] Teste HTTPS funcionando: `https://api.dnotas.com.br:9999`
- [ ] URL atualizada no APP Flutter

---

## Suporte

Se encontrar problemas, verifique os logs:

```cmd
# Logs da API (se rodando direto)
cd C:\ERP_SISTEMAS\APP_Dnotas\APIS_APP
npm start

# Logs do PM2 (se usando como serviço)
pm2 logs api-dnotas
```

---

**Última atualização**: 2025-01-17
