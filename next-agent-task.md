## Banco de Dados PostgreSQL – Progresso

✅ PostgreSQL instalado localmente via apt-get (porta 5432) e configurado.
✅ Script `database/postgres/schema.sql` criado com estrutura de tabelas e seeds.
✅ Script executado com sucesso em `boteco_dev`.
✅ Flutter instalado para futuras execuções do app.

🔜 Pendências:
- Adaptar serviços para apontar para esta instância e validar integração completa.
- Executar o aplicativo com um dispositivo compatível (Chrome ou desktop).
- Criar políticas RLS, views e procedures conforme necessário.

### Scripts adicionados
- `db_init/functions/` com stored procedures usadas pelo app (cadastro de fornecedores, produtos, vendas etc.)
- `db_init/views/` com views de leitura para fornecedores, categorias, produtos, vendas e pedidos
- `db_init/tables/` agora armazena `schema.sql` e `legacy_tables.sql`

### Próximos passos
- Revisar as definições das funções para garantir regras de negócio completas
- Implementar políticas de RLS para todas as tabelas
- Validar execução dos scripts em um container PostgreSQL local
