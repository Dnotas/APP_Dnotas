# 🚀 INSTRUÇÕES PARA CONFIGURAÇÃO COM DADOS REAIS

## 📋 O que foi removido:
✅ **Todas as simulações e dados mockados foram removidos**
✅ **APIs agora só funcionam com dados reais do Supabase**
✅ **Credenciais de demonstração removidas**
✅ **Formulários de login limpos**

## 🔧 CONFIGURAÇÃO NECESSÁRIA PARA SÁBADO:

### 1. **CONFIGURAR .ENV DO BACKEND (APIS_APP)**

Crie o arquivo `.env` na pasta `APIS_APP/` com suas credenciais do Supabase:

```bash
# Configurações do Servidor
PORT=3000
NODE_ENV=production

# Banco de Dados Supabase
DB_HOST=db.sua-referencia-projeto.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=SUA_SENHA_SUPABASE

# JWT (Gere uma chave segura)
JWT_SECRET=sua_chave_jwt_super_segura_aqui
JWT_EXPIRES_IN=24h

# Firebase (Para notificações push)
FIREBASE_PROJECT_ID=seu_projeto_firebase
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nSUA_CHAVE_PRIVADA_AQUI\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@seu-projeto.iam.gserviceaccount.com

# CORS
ALLOWED_ORIGINS=http://localhost:3001,https://seu-dominio.com
```

### 2. **COMO OBTER CREDENCIAIS SUPABASE:**

1. Acesse: https://supabase.com/dashboard
2. Vá no seu projeto DNOTAS
3. **Settings** → **Database**
4. Copie as informações de conexão:
   - Host
   - Database name 
   - User
   - Password
   - Port

### 3. **RODAR O SISTEMA:**

```bash
# Backend (APIS_APP)
cd APIS_APP
npm install
npm run build
npm start

# Site (SITE) 
cd SITE
npm install
npm run build
npm run preview

# App (APP) - Para testar no simulador
cd APP
flutter pub get
flutter run
```

### 4. **URLS DE PRODUÇÃO:**

Altere nos arquivos:

**APP/lib/services/api_service.dart:**
```dart
static const String baseUrl = 'https://sua-api.com'; // Substitua localhost
```

**SITE/src/services/api.ts:**
```typescript
baseURL: 'https://sua-api.com/api', // Substitua localhost
```

### 5. **CRIAR USUÁRIO ADMINISTRADOR:**

Execute no SQL Editor do Supabase:

```sql
-- Inserir filial matriz
INSERT INTO filiais (id, nome, codigo, ativo) 
VALUES ('matriz', 'Matriz', 'MTZ', true);

-- Inserir usuário admin
INSERT INTO users_api (id, email, nome, senha, filial_id)
VALUES (
  gen_random_uuid(),
  'admin@dnotas.com',
  'Administrador DNOTAS', 
  '$2a$12$hash_da_senha_admin123', -- Use bcrypt para gerar
  'matriz'
);
```

### 6. **TESTAR DADOS REAIS:**

Para testar, insira dados de exemplo:

```sql
-- Cliente de teste
INSERT INTO clientes (id, cnpj, nome_empresa, email, senha, filial_id, is_active)
VALUES (
  gen_random_uuid(),
  '12345678000123',
  'Empresa Teste Ltda',
  'teste@empresa.com',
  '$2a$12$hash_da_senha_123456', -- Use bcrypt
  'matriz',
  true
);

-- Relatório de vendas
INSERT INTO relatorios_vendas (
  id, cliente_id, cliente_cnpj, filial_id, data_relatorio,
  vendas_debito, vendas_credito, vendas_dinheiro, vendas_pix, vendas_vale, total_vendas
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM clientes WHERE cnpj = '12345678000123'),
  '12345678000123',
  'matriz',
  CURRENT_DATE,
  2500.00, 1800.50, 450.00, 1206.28, 0.00, 5956.78
);

-- Boleto de teste
INSERT INTO boletos (
  id, cliente_id, cliente_cnpj, filial_id, numero_boleto, valor,
  data_vencimento, status, linha_digitavel, codigo_barras
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM clientes WHERE cnpj = '12345678000123'),
  '12345678000123',
  'matriz',
  '00001',
  850.00,
  CURRENT_DATE + INTERVAL '7 days',
  'pendente',
  '34191.79001 01043.510047 91020.150008 1 85420000085000',
  '34191790010104351004791020150008185420000085000'
);
```

## ✅ **STATUS ATUAL:**

- ✅ **Banco de dados:** Configurado (Supabase)
- ✅ **APIs backend:** Prontas (sem simulação)  
- ✅ **APP Flutter:** Atualizado para APIs reais
- ✅ **SITE Vue.js:** Removido dados mockados
- 🔄 **Configuração .env:** Pendente (você precisa fazer)
- 🔄 **Teste end-to-end:** Pendente (após configurar .env)

## 🎯 **PRONTO PARA APRESENTAÇÃO DE SÁBADO!**

Após configurar o `.env` com suas credenciais reais, todo o sistema funcionará com dados reais do Supabase!