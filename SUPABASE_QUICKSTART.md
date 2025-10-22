# Quick Start - Configuração Supabase

Este guia rápido mostra como configurar o ambiente Supabase no BotecoPro em 5 minutos.

## ⚡ Início Rápido

### 1. Configure suas credenciais

```bash
# Copie o arquivo de exemplo
cp .env.example .env
```

Edite o arquivo `.env` e adicione suas credenciais do Supabase:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Execute o aplicativo

```bash
# Web
flutter run -d web

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 🔑 Onde obter as credenciais?

1. Acesse [https://app.supabase.com](https://app.supabase.com)
2. Entre no seu projeto (ou crie um novo)
3. Vá em **Settings** → **API**
4. Copie:
   - **Project URL** → `SUPABASE_URL`
   - **Project API Key (anon public)** → `SUPABASE_ANON_KEY`

## 📖 Documentação Completa

Para documentação detalhada, veja:
- [SUPABASE_SETUP_GUIDE.md](./SUPABASE_SETUP_GUIDE.md) - Guia completo de configuração e uso

## ✅ O que foi configurado?

- ✅ Dependências Supabase adicionadas (`supabase_flutter`, `flutter_dotenv`)
- ✅ Inicialização do Supabase no `main.dart`
- ✅ Serviço de autenticação (`SupabaseAuthService`)
- ✅ Variáveis de ambiente protegidas (`.env` no `.gitignore`)
- ✅ Documentação completa

## 🚀 Próximos Passos

Após configurar o ambiente, você pode:

1. **Criar telas de autenticação**
   - Login
   - Registro
   - Recuperação de senha

2. **Integrar com o banco de dados**
   - Migrar de SharedPreferences para Supabase
   - Implementar sincronização offline

3. **Adicionar features**
   - Login social (Google, Apple)
   - Upload de imagens
   - Notificações

## ⚠️ Importante

- **NUNCA** commite o arquivo `.env` com suas credenciais
- Use apenas a chave **anon/public** (não a service_role)
- Habilite Row Level Security (RLS) nas tabelas do Supabase

## 🐛 Problemas?

Consulte a seção [Troubleshooting](./SUPABASE_SETUP_GUIDE.md#-troubleshooting) no guia completo.

---

**Pronto!** Seu ambiente Supabase está configurado. 🎉
