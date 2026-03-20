# AGENTS.md

## Objetivo
Evoluir o BotecoPro App como produto real da Monynha Softwares: estável, escalável, pronto para backend seguro, com UX consistente em mobile/web/desktop e sem acoplamentos caóticos entre UI, persistência e regras de negócio.

## Repositórios
- `BotecoPro-app`: repositório principal e caminho oficial de evolução.
- `v0-BotecoPro-App`: referência histórica/MVP. Use apenas para comparação de fluxo, reaproveitamento pontual de UI/lógica ou validação de comportamento legado. Nunca use a v0 como destino principal de novas soluções.
- Se a v0 não estiver disponível no workspace atual, registre isso no `TODO.md` e siga pela base principal.

## Stack
- Flutter + Dart
- `provider` para estado simples atual
- `shared_preferences` para persistência local legada/operacional
- `flutter_secure_storage` para sessão/segredos locais em plataformas suportadas
- Estrutura em transição para separar `presentation`, `domain`, `data` e `core`

## Setup
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Estrutura relevante
```text
lib/
├── core/
│   ├── models/
│   ├── providers/
│   └── services/
├── data/
│   ├── local/
│   ├── remote/
│   └── repositories/
├── domain/
│   └── repositories/
├── presentation/
│   ├── pages/
│   └── widgets/
├── main.dart
└── theme.dart
```

## Convenções de arquitetura
- UI em `presentation` não deve conhecer detalhes de persistência nem endpoint remoto.
- Regras de autenticação, sincronização e integração externa devem passar por interfaces/repositórios.
- Sempre que possível, mover fluxos novos para a direção:
  - `presentation` → `provider/controller/state` → `domain repository/use case` → `data source/service`
- Não criar lógica crítica diretamente em widgets se ela puder ser extraída com segurança.
- Novas integrações remotas devem nascer em `lib/data/remote/` e ser consumidas via abstração.

## Persistência e segurança
- Não guardar credenciais, tokens ou segredos em `SharedPreferences` puro.
- Use `flutter_secure_storage` para dados sensíveis quando a plataforma suportar.
- `SharedPreferences` deve ser tratado como legado para dados operacionais simples até a migração.
- Toda mudança relevante de persistência deve considerar versionamento e estratégia de migração/rollback.
- Se mexer em exportação/importação, validar compatibilidade de schema e registrar impacto no `TODO.md`.

## Backend e sincronização
- Não hardcodar endpoints em páginas/widgets.
- Centralizar provider/config do backend em classes específicas de configuração.
- Prioridade de direção arquitetural:
  1. Supabase
  2. ou FastAPI + banco relacional
- Deixar sempre claro o que é mock, fallback local e integração real.
- Não quebrar compatibilidade futura com autenticação, multiutilizador e sincronização offline-first.

## Branding e UX
- Respeitar a identidade Monynha: visual mais institucional, menos cara de template genérico.
- Manter consistência entre splash, login, navegação e componentes recorrentes.
- Revisar responsividade ao mexer em layouts: mobile, tablet e desktop/web.
- Evitar textos placeholders quando impactarem a percepção de produto real.
- Quando fizer sentido, preservar assinatura institucional como “Marcelo Santos • Monynha Softwares”.

## Regras de edição segura
- Não reintroduzir lógica acoplada de forma caótica.
- Não misturar UI e lógica de autenticação/sync sem necessidade.
- Não remover abstrações novas para “simplificar” rapidamente.
- Não manter código morto ou legado redundante sem justificativa documentada.
- Ao encontrar limitação que não dará para resolver na iteração, documentar em `TODO.md` com ação objetiva.

## O que não deve ser feito
- Não hardcodar secrets, tokens, URLs privadas ou credenciais.
- Não fingir integração real com backend quando ela ainda for mock.
- Não salvar dados sensíveis sem proteção.
- Não usar a v0 como base principal para novos fluxos.
- Não concluir mudanças sem revisar impacto em autenticação, persistência, branding e responsividade.

## Regras de qualidade
- Rodar `flutter analyze` e `flutter test` sempre que o ambiente permitir.
- Se o ambiente não tiver Flutter/Dart, registrar explicitamente a limitação no `TODO.md` e no resumo final.
- Atualizar documentação quando criar stubs, contratos, TODOs técnicos ou novas decisões estruturais.
- Preferir refatoração incremental, segura e legível a grandes reescritas sem validação.

## Checklist final para qualquer agente
- [ ] Revisei os arquivos modificados e mantive coerência arquitetural.
- [ ] Não deixei endpoints, segredos ou credenciais hardcoded.
- [ ] Não coloquei dados sensíveis em armazenamento inseguro.
- [ ] Atualizei `TODO.md` com pendências reais.
- [ ] Mantive ou melhorei a identidade visual Monynha.
- [ ] Verifiquei impacto em mobile/tablet/desktop.
- [ ] Rodei `flutter analyze` / `flutter test` ou documentei por que não foi possível.
- [ ] Se comparei com a v0, documentei o que foi aproveitado e por quê.
