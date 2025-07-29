# Tarefas de Migração para Supabase

Estas tarefas acompanham a implementação da versão 1.0 baseada em Supabase e substituem o protótipo local.

1. **Modelagem do banco Supabase**
   - Replicar todas as tabelas do SQL Server no projeto Supabase.
   - Ativar Realtime e configurar RLS por empresa.
   - Versionar os scripts em `BotecoPro-Backend/database/supabase/schemas`.

2. **Dependências Flutter**
   - Adicionar `supabase_flutter`, `google_sign_in`, `flutter_local_notifications` e `firebase_messaging` no `pubspec.yaml`.

3. **Inicialização no `main.dart`**
   - Usar `Supabase.initialize()` com variáveis de ambiente.
   - Atualizar o `AuthWrapper` para esperar a inicialização.

4. **Serviço de Autenticação**
   - Criar `lib/services/supabase_auth_service.dart` com métodos de signUp, signIn e Google login.
   - Remover o mock de `AuthService`.
   - Ajustar o `AuthProvider` para escutar `onAuthStateChange`.

5. **Persistência de Dados**
   - Implementar `SupabaseDatabaseService` substituindo `SharedPreferences`.
   - Adaptar todos os providers (mesas, pedidos, produtos) para usar o novo serviço.
   - Utilizar `stream()` para atualizações em tempo real.

6. **Notificações Push**
   - Gravar `fcm_token` no perfil do usuário.
   - Criar função de borda no Supabase para disparar notificações em novos pedidos.

7. **Testes Automatizados**
   - Executar `flutter test` nos aplicativos.
   - Rodar os scripts em `scripts/` validando se o ambiente é configurado corretamente (CLI e Flutter).

8. **Refatoração de Scripts Codex**
   - Garantir que `codex_environment.sh` trate erros de download da Supabase CLI.
   - Adicionar validação das variáveis de ambiente e mensagens claras.

9. **Documentação**
   - Atualizar `README.md` com instruções de configuração das variáveis `.env`.
   - Registrar o passo a passo de deploy das migrações com `supabase db push`.

