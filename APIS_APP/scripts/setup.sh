#!/bin/bash

# DNOTAS API - Script de Configuração Inicial
# Este script automatiza a configuração inicial da API

set -e

echo "🚀 Iniciando configuração da DNOTAS API..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Verificar se o Node.js está instalado
if ! command -v node &> /dev/null; then
    print_error "Node.js não encontrado. Instale Node.js 18+ antes de continuar."
    exit 1
fi

# Verificar versão do Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js versão 18+ é necessária. Versão atual: $(node -v)"
    exit 1
fi

print_status "Node.js $(node -v) encontrado"

# Verificar se o PostgreSQL está instalado
if ! command -v psql &> /dev/null; then
    print_warning "PostgreSQL não encontrado. Certifique-se de ter PostgreSQL 14+ instalado."
    print_info "Instruções de instalação: https://www.postgresql.org/download/"
fi

# Instalar dependências
print_info "Instalando dependências..."
npm install
print_status "Dependências instaladas com sucesso"

# Criar arquivo .env se não existir
if [ ! -f .env ]; then
    print_info "Criando arquivo .env..."
    cp .env.example .env
    print_status "Arquivo .env criado"
    print_warning "IMPORTANTE: Configure as variáveis no arquivo .env antes de executar a API"
    
    # Gerar JWT_SECRET automaticamente
    JWT_SECRET=$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)
    sed -i.bak "s/seu_jwt_secret_muito_seguro_aqui/$JWT_SECRET/" .env && rm .env.bak
    print_status "JWT_SECRET gerado automaticamente"
else
    print_info "Arquivo .env já existe"
fi

# Perguntar se deve criar o banco de dados
read -p "Deseja criar/configurar o banco de dados PostgreSQL? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Solicitar informações do banco
    read -p "Nome do banco de dados [dnotas_db]: " DB_NAME
    DB_NAME=${DB_NAME:-dnotas_db}
    
    read -p "Usuário do PostgreSQL [postgres]: " DB_USER
    DB_USER=${DB_USER:-postgres}
    
    read -p "Host do PostgreSQL [localhost]: " DB_HOST
    DB_HOST=${DB_HOST:-localhost}
    
    read -p "Porta do PostgreSQL [5432]: " DB_PORT
    DB_PORT=${DB_PORT:-5432}
    
    # Atualizar .env com informações do banco
    sed -i.bak "s/DB_NAME=dnotas_db/DB_NAME=$DB_NAME/" .env && rm .env.bak
    sed -i.bak "s/DB_USER=postgres/DB_USER=$DB_USER/" .env && rm .env.bak
    sed -i.bak "s/DB_HOST=localhost/DB_HOST=$DB_HOST/" .env && rm .env.bak
    sed -i.bak "s/DB_PORT=5432/DB_PORT=$DB_PORT/" .env && rm .env.bak
    
    # Tentar criar o banco de dados
    print_info "Criando banco de dados '$DB_NAME'..."
    if createdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" 2>/dev/null; then
        print_status "Banco de dados '$DB_NAME' criado com sucesso"
    else
        print_warning "Banco de dados pode já existir ou erro de permissão"
    fi
    
    # Executar schema
    print_info "Executando schema do banco de dados..."
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f database_schema.sql > /dev/null 2>&1; then
        print_status "Schema do banco de dados executado com sucesso"
    else
        print_error "Erro ao executar schema. Verifique as configurações do banco."
    fi
else
    print_info "Configuração do banco de dados pulada"
    print_warning "Lembre-se de configurar o banco manualmente antes de executar a API"
fi

# Compilar TypeScript
print_info "Compilando TypeScript..."
npm run build
print_status "TypeScript compilado com sucesso"

# Verificar se tudo está funcionando
print_info "Verificando configuração..."

# Teste básico de sintaxe
if node -c dist/server.js > /dev/null 2>&1; then
    print_status "Código compilado sem erros"
else
    print_error "Erro na compilação do código"
    exit 1
fi

echo
print_status "Configuração inicial concluída com sucesso!"
echo
print_info "Próximos passos:"
echo "1. Configure as variáveis no arquivo .env (especialmente Firebase)"
echo "2. Execute 'npm run dev' para desenvolvimento"
echo "3. Execute 'npm start' para produção"
echo "4. Acesse http://localhost:3000/api-docs para ver a documentação"
echo "5. Teste o endpoint http://localhost:3000/health"
echo
print_warning "Não esqueça de configurar o Firebase para notificações push!"
echo

# Perguntar se deve iniciar em modo desenvolvimento
read -p "Deseja iniciar a API em modo desenvolvimento agora? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Iniciando API em modo desenvolvimento..."
    npm run dev
fi