## Plano para Tornar o BotecoPro Operacional

### 1. Scripts e banco de dados
- [ ] Corrigir `scripts/init_postgres.sh` para utilizar `supabase/tables/schema.sql`, aplicar `rls_policies.sql` e rodar `seed.sql` apenas quando requisitado.
- [ ] Ajustar `scripts/clone_repos.sh` para checar a existência das pastas antes de clonar e ler `GITHUB_TOKEN` do ambiente.

### 2. Autenticação e fluxo inicial
- [ ] Garantir que `AuthWrapper` seja o ponto de entrada no `main.dart` para exigir login antes da navegação.
- [ ] Remover contas de teste pré-preenchidas das telas de login e cadastro.
- [ ] Centralizar todas as operações de login, cadastro e reset de senha no `SupabaseAuthService` usando `supabase.auth`.

### 3. Internacionalização
- [ ] Adicionar `flutter_localizations` e gerar arquivos `.arb` para PT, EN, ES e FR.
- [ ] Substituir strings literais nas páginas por chamadas de tradução.
- [ ] Traduzir mensagens de erro do Supabase conforme o idioma escolhido e aplicar locale salvo pelo `UserProvider`.

### 4. Serviços e dados
- [ ] Finalizar `updateProduto` e `updateReceita` em `SupabaseDatabaseService` e atualizar `ServiceProvider.updateProduct` para alterar `produto_venda`.
- [ ] Remover ou implementar métodos `_syncProdutosVenda`, `_syncProducoes`, `_syncProducaoIngredientes` e `_syncEstoque`.
- [ ] Eliminar dependências do `ApiService` legado em todo o projeto.
- [ ] Revisar adaptadores em `lib/adapters/model_adapters.dart` para não usar valores padrão arbitrários e exigir todos os campos necessários.

### 5. Qualidade e testes
- [ ] Configurar pipeline CI (GitHub Actions) executando `flutter analyze`, `flutter test` e `supabase db lint`.
- [ ] Criar testes de fluxo para login, pedidos e estoque e corrigir avisos do linter.
- [ ] Documentar no README procedimentos para produção (RLS, índices, armazenamento de imagens e logs).
