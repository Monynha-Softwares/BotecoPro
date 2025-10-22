# Setup de Desenvolvimento - BotecoPro

Este guia orienta você através da configuração completa do ambiente de desenvolvimento do BotecoPro, incluindo a integração opcional com Supabase.

## 📋 Pré-requisitos

### Obrigatórios

- **Flutter SDK** 3.0+ ([Instruções de instalação](https://flutter.dev/docs/get-started/install))
- **Git** ([Download](https://git-scm.com/downloads))
- Editor de código (VS Code, Android Studio, ou IntelliJ IDEA)

### Opcionais (para features completas)

- **Supabase Account** - Para autenticação e banco de dados ([Criar conta](https://supabase.com))
- **Firebase Account** - Para deployment web ([Criar conta](https://firebase.google.com))

## 🚀 Configuração Básica (Obrigatória)

### 1. Clone o Repositório

```bash
git clone https://github.com/Monynha-Softwares/BotecoPro.git
cd BotecoPro
```

### 2. Instale as Dependências

```bash
flutter pub get
```

### 3. Verifique a Instalação

```bash
flutter doctor -v
```

Resolva quaisquer problemas indicados pelo comando acima.

### 4. Execute o Aplicativo

**Web (recomendado para desenvolvimento rápido):**
```bash
flutter run -d web
```

**Android (requer Android SDK):**
```bash
flutter run -d android
```

**iOS (requer macOS):**
```bash
flutter run -d ios
```

## 🔐 Configuração Supabase (Opcional)

### Quando Configurar?

Configure o Supabase se você planeja usar:
- ✅ Autenticação de usuários (login/registro)
- ✅ Banco de dados na nuvem
- ✅ Sincronização multi-dispositivo
- ✅ Armazenamento de arquivos

### Passos para Configuração

#### 1. Crie um Projeto no Supabase

1. Acesse [https://app.supabase.com](https://app.supabase.com)
2. Clique em "New Project"
3. Preencha:
   - **Nome**: BotecoPro (ou o nome que preferir)
   - **Database Password**: Escolha uma senha forte
   - **Região**: South America (São Paulo) para melhor latência
4. Aguarde a criação do projeto (~2 minutos)

#### 2. Obtenha as Credenciais

1. No dashboard do Supabase, vá para **Settings** → **API**
2. Copie:
   - **Project URL** (ex: `https://xxxxx.supabase.co`)
   - **Project API Key - anon public** (começa com `eyJ...`)

⚠️ **IMPORTANTE**: Use apenas a chave **anon public**, NUNCA use a **service_role**!

#### 3. Configure o Arquivo .env

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite o arquivo .env com suas credenciais
# Use seu editor favorito (nano, vim, VS Code, etc.)
nano .env
```

Cole suas credenciais:
```env
SUPABASE_URL=https://seu-projeto-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 4. Reinicie o Aplicativo

```bash
# Pare a execução atual (Ctrl+C) e execute novamente
flutter run -d web
```

### Verificar se Supabase Está Funcionando

Ao iniciar o app, verifique os logs do console. Você deve ver:
- ✅ Nenhum erro relacionado a Supabase
- ✅ Mensagem de inicialização bem-sucedida

Se vir warnings sobre .env não encontrado, o Supabase não está configurado (o que é OK se você não precisa dele ainda).

## 📁 Estrutura do Projeto

```
BotecoPro/
├── .env                    # Suas credenciais (não commitar!)
├── .env.example            # Template de credenciais
├── lib/
│   ├── main.dart           # Entry point
│   ├── theme.dart          # Temas e cores
│   ├── models/             # Modelos de dados
│   ├── services/           # Serviços (DB, Auth)
│   ├── pages/              # Telas do app
│   └── widgets/            # Componentes reutilizáveis
├── web/                    # Assets web
├── android/                # Projeto Android
├── ios/                    # Projeto iOS
└── pubspec.yaml            # Dependências
```

## 🛠️ Comandos Úteis

### Desenvolvimento

```bash
# Executar em modo debug
flutter run -d web

# Executar em modo verbose (para debugging)
flutter run -d web -v

# Hot reload (no terminal em execução)
# Pressione 'r' para reload
# Pressione 'R' para restart completo
# Pressione 'q' para quit

# Limpar build cache
flutter clean && flutter pub get
```

### Build

```bash
# Build para Web (produção)
flutter build web --release

# Build para Android (APK)
flutter build apk --release

# Build para Android (App Bundle)
flutter build appbundle --release

# Build para iOS (requer macOS)
flutter build ios --release
```

### Análise e Formatação

```bash
# Analisar código
flutter analyze

# Formatar código
dart format lib/

# Verificar dependências desatualizadas
flutter pub outdated
```

### Testes

```bash
# Executar todos os testes
flutter test

# Executar testes específicos
flutter test test/specific_test.dart

# Executar testes com coverage
flutter test --coverage
```

## 🔧 Configuração do Editor

### VS Code

**Extensões Recomendadas:**
- Flutter (Dart-Code.flutter)
- Dart (Dart-Code.dart-code)
- Bracket Pair Colorizer 2
- Error Lens
- GitLens

**Configurações (settings.json):**
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.previewFlutterUiGuides": true,
  "editor.formatOnSave": true,
  "editor.formatOnType": true,
  "[dart]": {
    "editor.rulers": [80],
    "editor.tabSize": 2
  }
}
```

### Android Studio / IntelliJ IDEA

**Plugins Recomendados:**
- Flutter
- Dart
- Rainbow Brackets

## 🐛 Troubleshooting

### Problema: "Flutter command not found"

**Solução:**
```bash
# Adicione Flutter ao PATH
export PATH="$PATH:/path/to/flutter/bin"

# Ou adicione ao .bashrc/.zshrc para permanente
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Problema: ".env file not found"

**Solução:**
```bash
# Crie o arquivo .env a partir do exemplo
cp .env.example .env

# Se você não precisa de Supabase agora, pode ignorar este erro
# O app funcionará normalmente sem autenticação
```

### Problema: "Failed to initialize Supabase"

**Causas possíveis:**
1. Credenciais incorretas no .env
2. URL ou chave inválida
3. Problema de conectividade

**Solução:**
1. Verifique se copiou as credenciais corretas do Supabase
2. Confirme que está usando a chave **anon public**
3. Teste sua conexão com internet

### Problema: Build falha com erro de dependências

**Solução:**
```bash
# Limpe e reinstale dependências
flutter clean
flutter pub get
flutter pub upgrade

# Se ainda falhar, delete pubspec.lock
rm pubspec.lock
flutter pub get
```

### Problema: App não atualiza após mudanças

**Solução:**
```bash
# Hot restart completo (no terminal em execução)
# Pressione 'R' (maiúsculo)

# Ou pare e reinicie
# Ctrl+C
flutter run -d web
```

## 📚 Recursos de Aprendizado

### Flutter
- [Documentação Oficial Flutter](https://flutter.dev/docs)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Widget Catalog](https://flutter.dev/docs/development/ui/widgets)

### Supabase
- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart)
- [Tutorial Flutter + Supabase](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)

### BotecoPro
- [README.md](./README.md) - Visão geral do projeto
- [SUPABASE_SETUP_GUIDE.md](./SUPABASE_SETUP_GUIDE.md) - Guia completo Supabase
- [SUPABASE_QUICKSTART.md](./SUPABASE_QUICKSTART.md) - Guia rápido Supabase
- [WEB_ARCHITECTURE.md](./WEB_ARCHITECTURE.md) - Arquitetura do sistema

## ✅ Checklist de Setup

Marque conforme completa cada etapa:

### Básico
- [ ] Flutter SDK instalado (`flutter --version` funciona)
- [ ] Repositório clonado
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] App executa (`flutter run -d web`)

### Supabase (Opcional)
- [ ] Conta Supabase criada
- [ ] Projeto Supabase criado
- [ ] Credenciais copiadas
- [ ] Arquivo `.env` criado e configurado
- [ ] App reiniciado sem erros

### Desenvolvimento
- [ ] Editor configurado (VS Code/Android Studio)
- [ ] Extensões/Plugins instalados
- [ ] Hot reload funcionando
- [ ] Análise de código sem erros (`flutter analyze`)

## 🎯 Próximos Passos

Após configurar o ambiente:

1. **Explore o código**
   - Leia `lib/main.dart` para entender o entry point
   - Explore `lib/pages/` para ver as telas
   - Revise `lib/services/` para entender os serviços

2. **Execute exemplos**
   - Teste funcionalidades existentes (mesas, produtos, pedidos)
   - Explore a interface em diferentes tamanhos de tela
   - Verifique localStorage no DevTools do navegador

3. **Faça modificações**
   - Altere cores no `theme.dart`
   - Adicione novos produtos de exemplo
   - Customize textos e labels

4. **Contribua**
   - Leia [CONTRIBUTING.md](./CONTRIBUTING.md) se existir
   - Crie uma branch para suas mudanças
   - Submeta Pull Request

## 🆘 Precisa de Ajuda?

- **Issues**: [GitHub Issues](https://github.com/Monynha-Softwares/BotecoPro/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Monynha-Softwares/BotecoPro/discussions)
- **Documentação**: Veja os guias na pasta raiz do projeto

---

**Pronto para começar!** 🚀

Qualquer dúvida, consulte a documentação ou abra uma issue.
