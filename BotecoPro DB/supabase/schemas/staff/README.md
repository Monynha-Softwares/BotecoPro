# BotecoPro Database

This repo defines the Supabase database for the BotecoPro app using schema-based structure.

---

## 🧭 Passo a Passo: Supabase CLI + GitHub Actions

---

### ✅ 1. Inicialize o Supabase CLI no seu repositório

No terminal, na raiz do repositório (ex: `botecopro-db-repo/`):

```bash
supabase init
```

Isso criará a pasta `.supabase/` e o arquivo `config.toml`.

> 🔐 Para projetos com schemas múltiplos, pode ser necessário ajustar manualmente o `config.toml`.

---

### ⚙️ 2. Configure o `config.toml` com schemas personalizados

```toml
[db]
shadow_schema = "_shadow"
schemas = [
  "public",
  "core",
  "order",
  "invoice",
  "client",
  "staff",
  "inventory",
  "auth"
]
```

---

### 🚀 3. Deploy manual local (para testar)

```bash
supabase db push
```

Isso aplicará toda a estrutura e functions ao seu projeto Supabase conectado.

---

### 🔐 4. Configure o token da Supabase no GitHub

1. Acesse [https://app.supabase.com/account/tokens](https://app.supabase.com/account/tokens)
2. Gere um novo token **com permissão `database.admin`**
3. Vá no seu repositório GitHub:

   * **Settings > Secrets > Actions**
   * Adicione: `SUPABASE_ACCESS_TOKEN`

---
