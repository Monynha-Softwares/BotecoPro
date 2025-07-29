## Banco de Dados PostgreSQL – Progresso

✅ PostgreSQL instalado localmente via apt-get (porta 5432) e configurado.
✅ Script `database/postgres/schema.sql` criado com estrutura de tabelas e seeds.
✅ Script executado com sucesso em `boteco_dev`.
✅ Flutter instalado para futuras execuções do app.

### Scripts adicionados
- `db_init/functions/` com stored procedures usadas pelo app (cadastro de fornecedores, produtos, vendas etc.)
- `db_init/views/` com views de leitura para fornecedores, categorias, produtos, vendas e pedidos
- `db_init/tables/` agora armazena `schema.sql` e `legacy_tables.sql`

### Próximos passos
- Revisar as definições das funções para garantir regras de negócio completas
- Revisar e implementar funções, tabelas em falta
- Criar e executar scripts com dados seeds
- Validar execução dos scripts em um container PostgreSQL local
