# API de Vendas - DNOTAS

API simples para registrar e consultar vendas diárias por modalidade de pagamento.

## Configuração

1. Copie o arquivo `.env.example` para `.env`:
```bash
cp .env.example .env
```

2. Configure as variáveis no arquivo `.env`:
```
SUPABASE_URL=sua_url_do_supabase
SUPABASE_ANON_KEY=sua_chave_anonima_do_supabase
PORT=1111
```

3. Instale as dependências:
```bash
npm install
```

4. Execute a API:
```bash
npm run dev
```

## Endpoints

### POST /vendas_hoje
Registra ou atualiza as vendas do dia para um cliente.

**Parâmetros obrigatórios:**
- `cnpj` (string): CNPJ do cliente

**Parâmetros opcionais:**
- `credito` (number): Valor vendas no crédito (padrão: 0)
- `debito` (number): Valor vendas no débito (padrão: 0) 
- `pix` (number): Valor vendas via PIX (padrão: 0)
- `vale` (number): Valor vendas com vale alimentação (padrão: 0)
- `dinheiro` (number): Valor vendas em dinheiro (padrão: 0)
- `transferencia` (number): Valor vendas via transferência (padrão: 0)
- `filial_id` (string): ID da filial (padrão: 'matriz')

**Exemplo de uso:**
```bash
curl -X POST http://localhost:1111/vendas_hoje \
  -H "Content-Type: application/json" \
  -d '{
    "cnpj": "12345678901234",
    "credito": 1500.50,
    "debito": 850.25,
    "pix": 1200.00,
    "vale": 300.75,
    "dinheiro": 150.00,
    "transferencia": 200.50
  }'
```

**Resposta de sucesso:**
```json
{
  "success": true,
  "message": "Vendas registradas com sucesso",
  "data": {
    "cnpj": "12345678901234",
    "data": "2024-12-15",
    "vendas": {
      "credito": 1500.50,
      "debito": 850.25,
      "pix": 1200.00,
      "vale": 300.75,
      "dinheiro": 150.00,
      "transferencia": 200.50,
      "total": 4201.00
    },
    "filial_id": "matriz"
  }
}
```

### GET /api/relatorios/vendas/:cnpj
Consulta as vendas do dia para um cliente (usado pelo APP).

**Parâmetros:**
- `cnpj` (URL): CNPJ do cliente
- `data` (query opcional): Data no formato YYYY-MM-DD (padrão: hoje)

**Exemplo:**
```bash
curl http://localhost:1111/api/relatorios/vendas/12345678901234?data=2024-12-15
```

## Funcionamento

1. A API automaticamente calcula o `total_vendas` somando todas as modalidades
2. Se já existir um registro para o CNPJ na data atual, ele será atualizado
3. Se não existir, um novo registro será criado
4. Todos os valores são armazenados na tabela `relatorios_vendas` do Supabase
5. O APP Flutter consulta essa mesma tabela para exibir os relatórios

### POST /api/solicitacoes/relatorio
Permite que clientes solicitem relatórios customizados para datas específicas.

**Parâmetros obrigatórios:**
- `cliente_cnpj` (string): CNPJ do cliente
- `data_inicio` (string): Data inicial no formato YYYY-MM-DD
- `data_fim` (string): Data final no formato YYYY-MM-DD  
- `tipo_periodo` (string): 'dia_unico' ou 'intervalo'

**Parâmetros opcionais:**
- `observacoes` (string): Observações sobre a solicitação
- `filial_id` (string): ID da filial (padrão: 'matriz')

**Exemplo:**
```bash
curl -X POST http://localhost:1111/api/solicitacoes/relatorio \
  -H "Content-Type: application/json" \
  -d '{
    "cliente_cnpj": "12345678901234",
    "data_inicio": "2024-12-01",
    "data_fim": "2024-12-31",
    "tipo_periodo": "intervalo",
    "observacoes": "Relatório mensal de dezembro"
  }'
```

### GET /api/solicitacoes/relatorio/:cnpj
Consulta todas as solicitações de relatório de um cliente.

### GET /api/admin/solicitacoes/pendentes
Lista todas as solicitações pendentes para o painel administrativo.

**Query parameters:**
- `filial_id` (opcional): Filtrar por filial específica

### POST /api/admin/relatorios/processar/:solicitacao_id
Permite que a empresa processe/preencha um relatório solicitado.

**Parâmetros:**
- `relatorios_dados` (array): Array com dados de cada dia do período
- `processado_por` (string): Nome/ID de quem processou

**Exemplo de dados:**
```json
{
  "processado_por": "João Silva",
  "relatorios_dados": [
    {
      "data_relatorio": "2024-12-01",
      "vendas_credito": 1500.00,
      "vendas_debito": 800.50,
      "vendas_pix": 950.25,
      "vendas_vale": 200.00,
      "vendas_dinheiro": 150.75,
      "vendas_transferencia": 300.00
    }
  ]
}
```

### GET /api/relatorios/processado/:solicitacao_id
Consulta o relatório processado de uma solicitação específica.

## Fluxo de Trabalho

1. **Cliente (APP):** Seleciona data/período no calendário → Envia solicitação
2. **Sistema:** Cria registro com status 'pendente' 
3. **Empresa (SITE):** Recebe notificação de nova solicitação
4. **Empresa (SITE):** Preenche valores e processa relatório
5. **Sistema:** Atualiza status para 'concluido'
6. **Cliente (APP):** Recebe notificação e pode visualizar relatório

## Status da API

Acesse `http://localhost:1111` para verificar se a API está online.