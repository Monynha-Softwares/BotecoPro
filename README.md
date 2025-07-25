# BotecoPro Monorepo

This repository holds all code for the **BotecoPro** ecosystem in a single place.

```
BotecoPro-Monorepo/
├── apps/
│   └── botecopro_flutter/         # Mobile app (Flutter)
├── backend/
│   ├── database/
│   │   └── supabase/           # SQL schemas, seeds and OpenAPI
│   ├── edge-functions/         # Supabase Functions
│   ├── services/               # Helper scripts and workers
│   └── .github/workflows/      # CI/CD workflows
├── docs/
│   └── AGENTS.md               # Codex agents guide
├── scripts/                    # Automation utilities
├── .env.example
└── README.md (this file)
```

## Getting started

1. Copy `.env.example` to `.env` and adjust the variables.
2. Run `./scripts/dev_start.sh` to boot the local environment.

Contributions are welcome!
