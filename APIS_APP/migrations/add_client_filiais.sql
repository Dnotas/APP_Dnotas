-- MIGRAÇÃO: Sistema de Filiais dos Clientes
-- Data: 2024-10-25
-- Descrição: Permite que clientes tenham suas próprias filiais (CNPJs adicionais)

-- Tabela para filiais dos clientes
CREATE TABLE IF NOT EXISTS client_filiais (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    matriz_cnpj VARCHAR(14) NOT NULL REFERENCES clientes(cnpj) ON DELETE CASCADE,
    filial_cnpj VARCHAR(14) UNIQUE NOT NULL,
    filial_nome VARCHAR(100) NOT NULL,
    endereco TEXT,
    telefone VARCHAR(20),
    email VARCHAR(100),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Garantir que filial não seja igual à matriz
    CONSTRAINT chk_filial_diferente_matriz CHECK (matriz_cnpj != filial_cnpj)
);

-- Índices para busca rápida
CREATE INDEX IF NOT EXISTS idx_client_filiais_matriz ON client_filiais(matriz_cnpj);
CREATE INDEX IF NOT EXISTS idx_client_filiais_cnpj ON client_filiais(filial_cnpj);

-- Trigger para atualizar updated_at
CREATE TRIGGER update_client_filiais_updated_at 
    BEFORE UPDATE ON client_filiais 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Função para buscar todas as filiais de um cliente (matriz + filiais)
CREATE OR REPLACE FUNCTION get_all_client_cnpjs(p_matriz_cnpj VARCHAR(14))
RETURNS TABLE (
    cnpj VARCHAR(14),
    nome VARCHAR(100),
    tipo VARCHAR(10),
    ativo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    -- Matriz
    SELECT 
        c.cnpj,
        c.nome_empresa as nome,
        'matriz'::VARCHAR(10) as tipo,
        c.is_active as ativo
    FROM clientes c 
    WHERE c.cnpj = p_matriz_cnpj
    
    UNION ALL
    
    -- Filiais
    SELECT 
        cf.filial_cnpj as cnpj,
        cf.filial_nome as nome,
        'filial'::VARCHAR(10) as tipo,
        cf.is_active as ativo
    FROM client_filiais cf 
    WHERE cf.matriz_cnpj = p_matriz_cnpj 
    AND cf.is_active = true;
END;
$$ LANGUAGE plpgsql;

-- View para facilitar consultas
CREATE OR REPLACE VIEW v_clients_with_filiais AS
SELECT 
    c.cnpj as matriz_cnpj,
    c.nome_empresa as matriz_nome,
    json_agg(
        json_build_object(
            'cnpj', all_cnpjs.cnpj,
            'nome', all_cnpjs.nome,
            'tipo', all_cnpjs.tipo,
            'ativo', all_cnpjs.ativo
        )
    ) as filiais
FROM clientes c
LEFT JOIN get_all_client_cnpjs(c.cnpj) all_cnpjs ON true
GROUP BY c.cnpj, c.nome_empresa;

-- Comentários
COMMENT ON TABLE client_filiais IS 'Filiais dos clientes - CNPJs adicionais que cada cliente pode ter';
COMMENT ON FUNCTION get_all_client_cnpjs IS 'Retorna matriz + todas as filiais de um cliente';

-- Log da migração (opcional - só se existir tabela schema_migrations)
-- INSERT INTO schema_migrations (version, description, executed_at) 
-- VALUES ('2024102501', 'Add client filiais system', CURRENT_TIMESTAMP)
-- ON CONFLICT (version) DO NOTHING;

-- Dados de exemplo (opcional - só para teste)
/*
-- Exemplo: Cliente Supermercado ABC tem 2 filiais
INSERT INTO client_filiais (matriz_cnpj, filial_cnpj, filial_nome) VALUES 
('12345678000195', '12345678000276', 'Supermercado ABC - Filial Shopping'),
('12345678000195', '12345678000357', 'Supermercado ABC - Filial Centro')
ON CONFLICT (filial_cnpj) DO NOTHING;
*/