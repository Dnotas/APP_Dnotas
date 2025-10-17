# DNOTAS API

API Backend para o aplicativo DNOTAS - Sistema de comunicação e gestão fiscal entre empresa de contabilidade e seus clientes.

## 📋 Sobre o Projeto

Esta API fornece endpoints para:
- **Relatórios de Vendas**: Consulta e gestão de relatórios diários de vendas
- **Área Financeira**: Gestão de boletos, pagamentos e extratos
- **Notificações Push**: Sistema completo de notificações em tempo real
- **Autenticação**: Sistema seguro com JWT e gestão de usuários

## 🚀 Tecnologias Utilizadas

- **Node.js** + **TypeScript** - Backend escalável e type-safe
- **Express.js** - Framework web minimalista
- **PostgreSQL** - Banco de dados relacional
- **Firebase Admin** - Notificações push
- **JWT** - Autenticação segura
- **Swagger** - Documentação da API
- **Docker** - Containerização (opcional)

## 📂 Estrutura do Projeto

```
APIS_APP/
├── src/
│   ├── config/          # Configurações (DB, Swagger, Cron)
│   ├── controllers/     # Controladores das rotas
│   ├── middleware/      # Middlewares (auth, error handling)
│   ├── models/          # Modelos de dados (futuro)
│   ├── routes/          # Definições de rotas
│   ├── services/        # Lógica de negócio
│   ├── types/           # Definições TypeScript
│   ├── utils/           # Utilitários
│   └── server.ts        # Ponto de entrada da aplicação
├── database_schema.sql  # Schema do banco PostgreSQL
├── package.json
├── tsconfig.json
└── README.md
```

## 🛠️ Instalação e Configuração

### 1. Pré-requisitos

- Node.js 18+ 
- PostgreSQL 14+
- Firebase Project (para notificações)

### 2. Instalação

```bash
# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env com suas configurações
```

### 3. Configuração do Banco de Dados

```bash
# Criar banco de dados PostgreSQL
createdb dnotas_db

# Executar schema
psql -d dnotas_db -f database_schema.sql
```

### 4. Configuração do Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Gere uma chave privada para Service Account
3. Configure as variáveis no `.env`:
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_PRIVATE_KEY`
   - `FIREBASE_CLIENT_EMAIL`
   - etc.

### 5. Executar a Aplicação

```bash
# Desenvolvimento
npm run dev

# Produção
npm run build
npm start

# Testes
npm test

# Lint
npm run lint
```

## 📚 Documentação da API

A documentação completa está disponível via Swagger UI:

- **Local**: http://localhost:9999/api-docs
- **Produção**: https://api.dnotas.com.br/api-docs

### Principais Endpoints

#### Autenticação
- `POST /api/auth/login` - Login do usuário
- `POST /api/auth/register` - Registro de novo usuário
- `PUT /api/auth/update-fcm-token` - Atualizar token FCM

#### Relatórios
- `GET /api/reports` - Listar relatórios do cliente
- `GET /api/reports/hoje` - Relatório do dia atual
- `GET /api/reports/estatisticas` - Estatísticas de vendas
- `POST /api/reports` - Criar relatório (admin)

#### Financeiro
- `GET /api/financial/boletos` - Listar boletos
- `GET /api/financial/boletos/pendentes` - Boletos pendentes
- `GET /api/financial/estatisticas` - Estatísticas financeiras
- `POST /api/financial/boletos` - Criar boleto (admin)

#### Notificações
- `GET /api/notifications` - Listar notificações
- `GET /api/notifications/nao-lidas` - Notificações não lidas
- `PUT /api/notifications/:id/lida` - Marcar como lida
- `POST /api/notifications` - Criar notificação (admin)

## 🔒 Autenticação

A API usa autenticação JWT. Inclua o token no header:

```
Authorization: Bearer {token}
```

## 🔔 Sistema de Notificações

### Tipos de Notificação
- **relatorio**: Novos relatórios de vendas
- **boleto**: Novos boletos ou vencimentos
- **inatividade**: Usuário inativo por muito tempo
- **geral**: Mensagens gerais da empresa

### Notificações Push
Utiliza Firebase Cloud Messaging (FCM) para envio de notificações push para dispositivos móveis.

## ⏰ Tarefas Agendadas (Cron Jobs)

- **09:00 diário**: Verificar boletos vencendo
- **10:00 segunda-feira**: Verificar clientes inativos
- **02:00 domingo**: Limpeza de notificações antigas
- **A cada hora**: Health check do sistema

## 🏗️ Arquitetura Multi-Filial

O sistema suporta múltiplas filiais com isolamento de dados:
- **Matriz**: Acesso total aos dados
- **Filiais**: Acesso apenas aos dados de sua filial
- **Clientes**: Acesso apenas aos próprios dados

## 🔧 Configuração de Produção

### Variáveis de Ambiente Importantes

```env
NODE_ENV=production
PORT=9999
DB_HOST=localhost
DB_NAME=dnotas_db
JWT_SECRET=seu_jwt_secret_muito_seguro
FIREBASE_PROJECT_ID=seu_projeto_firebase
```

### Recomendações de Segurança

1. **HTTPS**: Sempre use HTTPS em produção
2. **Rate Limiting**: Configure limites apropriados
3. **CORS**: Configure origins permitidas
4. **JWT Secret**: Use uma chave forte e única
5. **Firewall**: Configure regras de firewall no banco

### Monitoramento

- **Health Check**: `GET /health`
- **Logs**: Configurar logging estruturado
- **Métricas**: Implementar métricas de performance

## 🚀 Deploy

### Docker (Recomendado)

```dockerfile
# Dockerfile básico (criar conforme necessário)
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY dist ./dist
EXPOSE 9999
CMD ["node", "dist/server.js"]
```

### Deploy Manual

```bash
# Build da aplicação
npm run build

# Instalar apenas dependências de produção
npm ci --only=production

# Executar
NODE_ENV=production npm start
```

## 🧪 Testes

```bash
# Executar todos os testes
npm test

# Testes com coverage
npm run test:coverage

# Testes em modo watch
npm run test:watch
```

## 📊 Performance

### Otimizações Implementadas

- **Índices de banco**: Otimização de queries
- **Connection Pooling**: Reutilização de conexões
- **Compressão**: Compressão de respostas HTTP
- **Rate Limiting**: Prevenção de spam
- **Caching**: Cache de queries frequentes

### Monitoramento de Performance

- **Query Logging**: Logs de queries SQL
- **Response Time**: Medição de tempo de resposta
- **Memory Usage**: Monitoramento de memória
- **Database Connections**: Monitoramento de conexões

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é propriedade da empresa DNOTAS. Todos os direitos reservados.

## 📞 Suporte

Para suporte técnico:
- **Email**: dev@dnotas.com
- **Documentação**: Swagger UI disponível em `/api-docs`
- **Issues**: GitHub Issues para bugs e melhorias

## 📝 Changelog

### v1.0.0 (2024)
- ✅ Sistema de autenticação JWT
- ✅ APIs de relatórios de vendas
- ✅ APIs financeiras (boletos)
- ✅ Sistema de notificações push
- ✅ Tarefas agendadas (cron jobs)
- ✅ Documentação Swagger
- ✅ Arquitetura multi-filial
- ✅ Schema do banco PostgreSQL