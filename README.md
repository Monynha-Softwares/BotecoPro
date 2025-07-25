# BotecoPro Monorepo

Este repositório concentra todo o código do ecossistema **BotecoPro** em um único lugar.

```
BotecoPro-Monorepo/
├── apps/
│   └── boteco_flutter/         # Aplicativo móvel (Flutter)
├── backend/
│   ├── database/
│   │   └── supabase/           # Schemas SQL, seeds e OpenAPI
│   ├── edge-functions/         # Funções do Supabase
│   ├── services/               # Scripts auxiliares
│   └── .github/workflows/      # Workflows de CI/CD
├── docs/
│   └── AGENTS.md               # Guia para agentes Codex
├── scripts/                    # Automação e utilitários
├── .env.example
└── README.md (este arquivo)
```

## Como começar

1. Copie `.env.example` para `.env` e ajuste as variáveis.
2. Execute `./scripts/dev_start.sh` para iniciar o ambiente local.

Contribuições são bem-vindas!
