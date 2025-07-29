# 🛠 Setup de Ambiente - Monynha Codex

Este conjunto de scripts automatiza a configuração do ambiente de desenvolvimento para os projetos da Monynha Softwares.

## 📁 Estrutura de Scripts

- `scripts/bootstrap.sh`: script principal que orquestra toda a configuração.
- `scripts/check_env.sh`: valida as variáveis de ambiente obrigatórias.
- `scripts/setup_git.sh`: configura nome e e-mail globais do Git.
- `scripts/install_postgres.sh`: instala o Docker e inicia um container Postgres.
- `scripts/install_flutter.sh`: instala e valida o Flutter SDK.
- `scripts/clone_repos.sh`: clona os repositórios BotecoPro.

## ✅ Variáveis esperadas

Defina essas variáveis de ambiente antes de rodar o `bootstrap.sh`:

```env
POSTGRES_PASSWORD=boteco
GITHUB_TOKEN=
```

## 🚀 Como usar

```bash
chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

Pronto! Ambiente Postgres + Flutter + GitHub configurado.
