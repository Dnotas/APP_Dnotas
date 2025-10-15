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
PORT=3000
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
curl -X POST http://localhost:3000/vendas_hoje \
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
curl http://localhost:3000/api/relatorios/vendas/12345678901234?data=2024-12-15
```

## Funcionamento

1. A API automaticamente calcula o `total_vendas` somando todas as modalidades
2. Se já existir um registro para o CNPJ na data atual, ele será atualizado
3. Se não existir, um novo registro será criado
4. Todos os valores são armazenados na tabela `relatorios_vendas` do Supabase
5. O APP Flutter consulta essa mesma tabela para exibir os relatórios

## Status da API

Acesse `http://localhost:3000` para verificar se a API está online.