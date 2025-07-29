## 🔧 Tarefas identificadas automaticamente – Auditoria Codex

### Bugs críticos
- [ ] `ServiceProvider.updateProduct` chama `_supabaseService.updateProduto`, mas esse método não existe em `supabase_database_service.dart`.
- [ ] `ServiceProvider.updateRecipe` depende de `_supabaseService.updateReceita`, também ausente no serviço Supabase.
- [ ] Script `scripts/init_postgres.sh` referencia `database/postgres/schema.sql`, porém o schema está em `db_init/tables/schema.sql`.
- [ ] `scripts/clone_repos.sh` clona repositórios sem checar se as pastas já existem, podendo sobrescrever dados locais.

### Inconsistências estruturais
- [ ] Métodos de sincronização `_syncProdutosVenda`, `_syncProducoes`, `_syncProducaoIngredientes` e `_syncEstoque` em `service_provider.dart` estão vazios.
- [ ] Várias operações de produção ainda utilizam `ApiService` ao invés de `SupabaseDatabaseService`, contrariando a migração para Supabase.

### Melhorias de código
- [ ] Implementar atualização de `produto_venda` em `updateProduct` quando o schema do Supabase estiver finalizado.
- [ ] Criar métodos `updateProduto` e `updateReceita` em `SupabaseDatabaseService` para permitir edição de produtos e receitas.
- [ ] Ajustar `check_env.sh` para validar também `POSTGRES_HOST` e `POSTGRES_PORT`.

### Scripts SQL com falhas
- [ ] Revisar `db_init/tables/rls_policies.sql` para garantir que todas as tabelas referenciadas existem e que as políticas cobrem inserts e updates.

### Requisitos pendentes do app
- [ ] Finalizar a substituição do `ApiService` antigo por chamadas diretas ao Supabase em todas as telas.
- [ ] Validar a criação de dados iniciais e seeds utilizando os scripts em `db_init/`.
