# Sistema de Chat de Suporte - Scripts SQL

Este diretório contém os scripts SQL necessários para implementar o sistema completo de chat de suporte entre clientes (APP) e funcionários (SITE).

## Arquivos

### 1. `01_chat_system_tables.sql`
**Descrição**: Cria todas as tabelas e estruturas necessárias para o sistema de chat.

**Tabelas criadas**:
- `chat_conversations`: Conversas de suporte
- `chat_messages`: Mensagens das conversas
- `funcionarios`: Funcionários que atendem o chat
- `chat_templates`: Templates de mensagens
- `chat_avaliacoes`: Avaliações de atendimento

**Execução**: Execute este arquivo primeiro no Supabase.

### 2. `02_chat_functions.sql`
**Descrição**: Cria funções específicas para operações do chat.

**Funções criadas**:
- `iniciar_conversa_suporte()`: Inicia nova conversa (cliente)
- `enviar_mensagem_chat()`: Envia mensagem
- `marcar_mensagens_lidas()`: Marca mensagens como lidas
- `assumir_atendimento()`: Funcionário assume conversa
- `finalizar_conversa()`: Finaliza atendimento
- `buscar_conversas_atendimento()`: Lista conversas (SITE)
- `buscar_conversas_cliente()`: Lista conversas (APP)
- `buscar_mensagens_conversa()`: Busca mensagens
- `obter_stats_funcionario()`: Estatísticas do funcionário
- `limpar_conversas_antigas()`: Limpeza automática

**Execução**: Execute após o arquivo de tabelas.

## Como Executar

### 1. No Supabase Dashboard
1. Acesse o Supabase Dashboard
2. Vá para **SQL Editor**
3. Execute os arquivos na ordem:
   - Primeiro: `01_chat_system_tables.sql`
   - Segundo: `02_chat_functions.sql`

### 2. Via CLI do Supabase
```bash
# Executar tabelas
supabase db reset --file sql/01_chat_system_tables.sql

# Executar funções
supabase db reset --file sql/02_chat_functions.sql
```

## Estrutura do Sistema

### Fluxo de Funcionamento

#### 1. **Cliente inicia conversa (APP)**
- Cliente escolhe assunto e descrição
- Sistema cria nova conversa com status "aberto"
- Conversa fica disponível para funcionários

#### 2. **Funcionário assume atendimento (SITE)**
- Funcionários veem lista de conversas abertas
- Podem assumir atendimento de qualquer conversa
- Status muda para "em_atendimento"

#### 3. **Troca de mensagens**
- Cliente e funcionário trocam mensagens em tempo real
- Sistema controla mensagens não lidas
- Suporte a arquivos (PDF, imagens, etc.)

#### 4. **Finalização**
- Funcionário finaliza a conversa
- Status muda para "finalizado"
- Cliente pode avaliar o atendimento

### Separação de Responsabilidades

#### **SITE (Vue.js) - Funcionários**
- Ver lista de conversas por filial
- Assumir atendimento
- Responder mensagens
- Enviar arquivos/links
- Finalizar conversas
- Ver estatísticas
- Usar templates de mensagens

#### **APP (Flutter) - Clientes**
- Iniciar nova conversa
- Ver lista de conversas
- Enviar mensagens
- Enviar arquivos
- Receber notificações
- Avaliar atendimento

### Isolamento por Filial

- Cada funcionário só vê conversas de sua filial
- Clientes são automaticamente associados à sua filial
- Sistema mantém segregação de dados
- Estatísticas separadas por filial

## Configurações Importantes

### Row Level Security (RLS)
Todas as tabelas possuem RLS habilitado para segurança.

### Índices de Performance
Criados índices otimizados para:
- Busca de conversas por filial
- Ordenação por data/prioridade
- Contagem de mensagens não lidas

### Triggers Automáticos
- Contadores de mensagens não lidas
- Atualização de timestamps
- Controle de status das conversas

## Dados Iniciais

### Funcionários Padrão
- Admin Matriz: `admin@matriz.dnotas.com`
- Admin Filial 1: `admin@filial1.dnotas.com`  
- Admin Filial 2: `admin@filial2.dnotas.com`

Senha padrão (hash): `$2a$12$example_hashed_password`

### Templates Básicos
- Saudação inicial
- Aguardar documentos
- Finalização

## Manutenção

### Limpeza Automática
Execute periodicamente para limpar conversas antigas:
```sql
SELECT limpar_conversas_antigas(90); -- Remove conversas finalizadas há mais de 90 dias
```

### Backup
Recomenda-se backup regular das tabelas:
- `chat_conversations`
- `chat_messages`
- `funcionarios`
- `chat_avaliacoes`

## Próximos Passos

Após executar os scripts SQL:
1. Implementar APIs no backend (APIS_APP)
2. Criar interface no SITE (Vue.js)
3. Implementar chat no APP (Flutter)
4. Configurar notificações em tempo real
5. Implementar upload de arquivos

## Suporte

Para dúvidas sobre os scripts SQL, consulte:
- Documentação do PostgreSQL
- Documentação do Supabase
- Logs do sistema (`RAISE NOTICE` nos scripts)