# Tarefas de Correção e Migração para Supabase

Este arquivo lista as principais tarefas para corrigir os problemas encontrados na análise da versão 0 do Boteco PRO e concluir a migração para o backend Supabase.

## 1. Configuração do Supabase

- [ ] Criar projeto no Supabase, obtendo `SUPABASE_URL` e `SUPABASE_ANON_KEY`.
- [ ] Modelar tabelas e funções no diretório `BotecoPro-Backend/database/supabase` replicando as entidades: `fornecedores`, `categorias`, `produtos`, `produtos_venda`, `mesas`, `pedidos`, `pedido_itens`, `vendas` etc.
- [ ] Habilitar o Realtime e configurar políticas de Row Level Security (RLS) para cada tabela.
- [ ] Versionar scripts de seed e roles dentro de `database/supabase`.

## 2. Ajustes na Aplicação Flutter

- [x] Adicionar dependências `supabase_flutter`, `google_sign_in`, `flutter_local_notifications` e `firebase_messaging` em `pubspec.yaml`.
- [x] Inicializar o Supabase em `main.dart` utilizando as variáveis de ambiente.
- [x] Implementar `supabase_auth_service.dart` com métodos de cadastro, login (email e Google), recuperação de senha e logout.
- [x] Atualizar `AuthProvider` para utilizar `supabase.auth.onAuthStateChange`.
- [x] Substituir `DatabaseService` por `SupabaseDatabaseService` em todo o app, removendo persistência via `SharedPreferences`.
- [ ] Implementar streams de atualização em tempo real (`supabase.from(...).stream`) para pedidos e estoque.
- [x] Ajustar telas de login e registro para tratar erros do Supabase.
- [x] Implementar streams de atualização em tempo real (`supabase.from(...).stream`) para pedidos e estoque.
- [ ] Ajustar telas de login e registro para tratar erros do Supabase.

## 3. Notificações e Edge Functions

- [ ] Armazenar token de push (`expo_push_token` ou `fcm_token`) em tabela de perfis/usuários.
- [ ] Criar função de borda no Supabase que envie push quando um novo pedido for inserido.
- [ ] Configurar webhook no Supabase chamando essa função.

## 4. Scripts do Codex

- [ ] Revisar `scripts/bootstrap.sh` e `codex_environment.sh` para garantir que não clonam repositórios quando já existem.
- [ ] Validar se todas as variáveis de ambiente são verificadas corretamente em `check_env.sh`.
- [ ] Criar um teste simples (shell) que execute os scripts em modo dry‑run para confirmar que a instalação do Supabase CLI e do Flutter ocorre sem erros.

## 5. Testes Gerais

- [ ] Testar cadastro, login e recuperação de sessão em Android, iOS e web.
- [ ] Testar operações CRUD de cada módulo (fornecedores, produtos, mesas, pedidos etc.).
- [ ] Validar fluxo em tempo real abrindo o app em dois dispositivos simultaneamente.
- [ ] Verificar se as notificações push são disparadas quando um pedido é criado.

## 6. Limpeza

- [x] Armazenar `SUPABASE_URL` e `SUPABASE_ANON_KEY` em arquivos `.env`, mantendo o `.env.example` atualizado.
- [ ] Remover código de protótipo não mais utilizado (classes de mock e gravação em `SharedPreferences`).

