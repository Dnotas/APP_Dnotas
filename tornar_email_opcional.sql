-- Tornar o campo email opcional na tabela clientes

-- Comando para permitir NULL no campo email
ALTER TABLE clientes ALTER COLUMN email DROP NOT NULL;