# 🛠 Setup de Ambiente - Monynha Codex

Este conjunto de scripts automatiza a configuração do ambiente de desenvolvimento para os projetos da Monynha Softwares.

## 📁 Estrutura de Scripts

- `scripts/bootstrap.sh`: script principal que orquestra toda a configuração.
- `scripts/check_env.sh`: valida as variáveis de ambiente obrigatórias.
- `scripts/setup_git.sh`: configura nome e e-mail globais do Git.
- `scripts/setup_postgres.sh`: sobe o contêiner Docker com o Postgres local.
- `scripts/install_flutter.sh`: instala e valida o Flutter SDK.
- `scripts/clone_repos.sh`: clona os repositórios BotecoPro.

## ✅ Variáveis esperadas

Defina essas variáveis de ambiente antes de rodar o `bootstrap.sh`:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
GITHUB_TOKEN=
POSTGRES_USER=boteco
POSTGRES_PASSWORD=boteco
POSTGRES_DB=boteco_dev
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
```

## 🚀 Como usar

```bash
chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

Pronto! Ambiente com Postgres local, Flutter e GitHub configurado.
