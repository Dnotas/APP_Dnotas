    project id:
    cqqeylhspmpilzgmqfiu
    project name 
    suporte@dnotas.com.br's Project
    project url
    https://cqqeylhspmpilzgmqfiu.supabase.co

    anonpublic
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MTgxNTcsImV4cCI6MjA3NTA5NDE1N30.sPk51xxT7KBFp0_KC674PS62nwXNtBpo7UCKRm6ZEeY

service_rolesecret
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxcWV5bGhzcG1waWx6Z21xZml1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUxODE1NywiZXhwIjoyMDc1MDk0MTU3fQ.TiH1LEOH7i7tT2fCjfSr2GP12-JwIU3v6EYtyQotZBI


estrutura das tabelas 
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clientes' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

[
  {
    "column_name": "id",
    "data_type": "uuid",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "cnpj",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "nome_empresa",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "email",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "telefone",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "filial_id",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "created_at",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": "now()"
  },
  {
    "column_name": "last_login",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "is_active",
    "data_type": "boolean",
    "is_nullable": "YES",
    "column_default": "true"
  },
  {
    "column_name": "senha",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "fcm_token",
    "data_type": "text",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "reset_token",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "reset_token_expiry",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": null
  }
]



-- Ver estrutura da tabela filiais
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'filiais' 
    AND table_schema = 'public'
ORDER BY ordinal_position;


[
  {
    "column_name": "id",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "nome",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "created_at",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": "now()"
  },
  {
    "column_name": "cnpj_empresa",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "codigo",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "ativo",
    "data_type": "boolean",
    "is_nullable": "YES",
    "column_default": "true"
  }
]


SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'funcionarios' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

[
  {
    "column_name": "id",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "nome",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "email",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "senha",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "cargo",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "organizacao_id",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "role",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": "'operator'::character varying"
  },
  {
    "column_name": "cpf",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "telefone",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "ativo",
    "data_type": "boolean",
    "is_nullable": "NO",
    "column_default": "true"
  },
  {
    "column_name": "ultimo_login",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "created_at",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": "CURRENT_TIMESTAMP"
  },
  {
    "column_name": "updated_at",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": "CURRENT_TIMESTAMP"
  },
  {
    "column_name": "auth_user_id",
    "data_type": "uuid",
    "is_nullable": "YES",
    "column_default": null
  }
]