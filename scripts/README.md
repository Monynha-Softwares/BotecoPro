# 🛠 Setup de Ambiente - Monynha Codex

Este conjunto de scripts automatiza a configuração do ambiente de desenvolvimento para os projetos da Monynha Softwares.

## 📁 Estrutura de Scripts

- `scripts/bootstrap.sh`: script principal que orquestra toda a configuração.
- `scripts/check_env.sh`: valida as variáveis de ambiente obrigatórias.
- `scripts/setup_git.sh`: configura nome e e-mail globais do Git.
- `scripts/install_supabase.sh`: instala e autentica o Supabase CLI.
- `scripts/install_flutter.sh`: instala e valida o Flutter SDK.
- `scripts/clone_repos.sh`: clona os repositórios BotecoPro.

## ✅ Variáveis esperadas

Defina essas variáveis de ambiente antes de rodar o `bootstrap.sh`:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_PROJECT_ID=
SUPABASE_CLI_VERSION=1.170.6
GITHUB_TOKEN=
# SUPABASE_SERVICE_ROLE_KEY= (opcional)
# SUPABASE_ACCESS_TOKEN= (opcional)
```

## 🚀 Como usar

```bash
chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

Pronto! Ambiente Supabase + Flutter + GitHub configurado.
