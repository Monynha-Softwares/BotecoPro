# TODO

## Estado atual
- A base principal segue como fonte de evolução; a versão `v0-BotecoPro-App` não está presente neste workspace e deve ser consultada apenas externamente quando for realmente necessária para comparação visual ou reaproveitamento pontual.
- O app agora possui um fluxo de autenticação local desacoplado da UI, com `AuthProvider` + `AuthRepository`, persistência de sessão e preparação explícita para backend remoto/sincronização.
- O tema foi consolidado com identidade Monynha mais consistente, splash/login/signup responsivos e linguagem visual menos genérica.
- A persistência local continua baseada em `SharedPreferences` para os dados operacionais, mas já existe metadado de schema e export/import de snapshot para apoiar migração futura.

## O que foi concluído
- Estruturado fluxo inicial de autenticação local com repositório, provider, navegação condicional e logout.
- Adicionada camada `data/domain` mínima para desacoplar autenticação e preparar backend remoto.
- Introduzido `flutter_secure_storage` para sessão/credenciais sensíveis em plataformas suportadas, com fallback controlado no web.
- Criado `RemoteBackendConfig` e `RemoteSyncService` como base para futura integração com Supabase ou FastAPI sem hardcode na UI.
- Melhorado branding Monynha no `theme.dart`, splash e telas de acesso.
- Adicionados `exportSnapshot()` e `importSnapshot()` no `DatabaseService`, além de metadado de versão de schema local.
- Atualizado `AGENTS.md` com regras de continuidade mais objetivas.

## Pendências críticas
- Integrar `flutter pub get`, `flutter analyze` e `flutter test` em ambiente com Flutter instalado para validar a iteração atual.
- Substituir autenticação local por implementação real com backend seguro, incluindo refresh token, expiração de sessão e política multiusuário.
- Migrar persistência operacional de `SharedPreferences` para solução robusta (`Hive`, `Drift` ou SQLite estruturado com migrations reais).
- Definir estratégia de sincronização offline-first com resolução de conflito e fila transacional.

## Pendências importantes
- Revisar warnings/lints do projeto em ambiente com SDK Flutter disponível.
- Extrair mais widgets compartilhados de páginas de CRUD para reduzir duplicação de cards, formulários e dialogs.
- Adicionar camada de casos de uso para estoque, fechamento de pedido e produção interna.
- Conectar export/import a uma UI de backup/restauração com confirmação e validação de versão.
- Refinar navegação mobile para expor ações de sessão/perfil em todas as telas, sem depender apenas da navegação principal.
- Mapear e documentar a estrutura esperada do backend (auth, catálogo, pedidos, sync jobs, auditoria).

## Melhorias incrementais
- Criar design tokens extras para breakpoints, raios, elevações e estados de feedback.
- Implementar empty states e loading states mais uniformes nas telas de produtos, mesas, receitas e produção.
- Adicionar testes unitários para `AuthProvider`, `LocalAuthRepository` e serialização/exportação do `DatabaseService`.
- Criar CI com etapas mínimas: format, analyze, test e build web.
- Adicionar tela “Sobre” com assinatura institucional da Monynha Softwares / Marcelo Santos.

## Bugs e limitações conhecidas
- Não foi possível rodar `flutter analyze` nem `flutter test` neste ambiente porque `flutter`/`dart` não estão instalados.
- O fallback web de `SecureStorageService` é apenas preparatório; ele não substitui segurança de backend nem criptografia de ponta a ponta.
- `RemoteSyncService` ainda é um stub de arquitetura e não executa sincronização real.
- Parte da UI principal ainda usa serviços diretamente (`DatabaseService`) sem passar por repositórios/casos de uso.
- Algumas telas antigas podem manter oportunidades de limpeza de imports, refino de responsividade e unificação de copy.

## Próximos passos recomendados
1. Instalar Flutter no ambiente e executar `flutter pub get`, `flutter analyze` e `flutter test`.
2. Escolher a trilha oficial de backend: Supabase ou FastAPI + banco relacional.
3. Implementar `RemoteAuthRepository` mantendo a mesma interface de `AuthRepository`.
4. Migrar gradualmente módulos críticos para repositórios e casos de uso (`orders`, `products`, `tables`).
5. Planejar migração de dados local com versionamento e rotina de rollback.
6. Criar testes automatizados para login, sessão local e export/import de snapshot.

## Observações para o próximo agente
- Não reintroduzir lógica de autenticação diretamente nas páginas.
- Não hardcodar endpoints nem secrets; centralizar tudo em config remota.
- Atualizar este arquivo sempre que deixar stubs, limitações temporárias ou débito técnico novo.
- Se a `v0-BotecoPro-App` for necessária numa próxima iteração, documentar exatamente quais fluxos foram comparados e o que foi reaproveitado.

## Prioridades
### Crítica
- Backend real de autenticação e sincronização.
- Migração da persistência operacional para armazenamento estruturado com migrations.
- Validação do projeto com ferramentas Flutter em ambiente apropriado.

### Importante
- Repositórios/casos de uso para módulos operacionais.
- Testes automatizados cobrindo sessão, estoque e fechamento de pedido.
- Padronização adicional de widgets e feedback visual.

### Incremental
- Tela institucional “Sobre”.
- Biblioteca visual compartilhada mais completa.
- Ajustes finos de copy e microinterações.
