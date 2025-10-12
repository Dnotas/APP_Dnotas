-- Verificar e corrigir problema da filial_id

-- 1. Ver quais filiais existem
SELECT id, nome, codigo FROM filiais;

-- 2. Inserir uma filial "Matriz" se não existir
INSERT INTO filiais (id, nome, codigo, ativo) 
VALUES ('matriz-id', 'Matriz', 'MATRIZ', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Verificar se foi inserida
SELECT id, nome, codigo FROM filiais WHERE id = 'matriz-id';