# ✨ Boteco PRO - Sistema de Gestão para Bares
[![Flutter 3.32](https://img.shields.io/badge/Flutter-3.32-blue?logo=flutter)](https://flutter.dev) [![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Boteco PRO is a **cross-platform management system for small Brazilian bars (“botecos”)**.
It helps owners keep tables, orders, stock, recipes and in-house production under control – whether the app is installed on Android, iOS or opened as a PWA in the browser.

## 🚀 Funcionalidades

- ✅ **Autenticação completa** - Login com email/senha e Google Sign-In
- ✅ **Gestão de mesas** - Controle de ocupação em tempo real
- ✅ **Controle de estoque** - Monitoramento automático de produtos
- ✅ **Pedidos e vendas** - Sistema completo de comandas
- ✅ **Fornecedores** - Cadastro e gestão de fornecedores
- ✅ **Receitas** - Cadastro de receitas e produções caseiras
- ✅ **Relatórios** - Dashboard com vendas diárias
- ✅ **Tempo real** - Atualizações automáticas via Supabase

## 🛠️ Tecnologias

- **Frontend:** Flutter (Dart)
- **Backend:** PostgreSQL (Docker) em desenvolvimento / Supabase em produção
- **Autenticação:** Supabase Auth + Google Sign-In
- **Estado:** Provider Pattern
- **UI:** Material Design 3

## 🔒 Segurança

- **Row Level Security (RLS):** Cada usuário só acessa seus próprios dados
- **Autenticação JWT:** Tokens seguros gerenciados pelo Supabase
- **Validação server-side:** Políticas de segurança no banco de dados
- **HTTPS:** Todas as comunicações são criptografadas

## 📱 Como Usar

### Primeiro Acesso
1. Cadastre-se com email/senha ou Google
2. O sistema criará dados de exemplo automaticamente
3. Explore as funcionalidades do dashboard

### Funcionalidades Principais
- **Dashboard:** Visão geral das vendas e mesas
- **Mesas:** Controle de ocupação em tempo real
- **Produtos:** Cadastro e controle de estoque
- **Pedidos:** Sistema de comandas
- **Fornecedores:** Gestão de fornecedores
- **Receitas:** Cadastro de receitas próprias


## 🧪 Testes

Exemplos de testes:

```bash
flutter doctor
flutter test
dart analyse
dart fix --apply
flutter run -d Chrome

```
Sempre execute `flutter doctor` para verificar se existem componentes em falta. Se necessário, instale-os.
Uma pipeline do **GitHub Actions** roda automaticamente em cada *push* e *pull request*,
executando `flutter analyze` e `flutter test` para garantir a qualidade do código.
Os relatórios de cobertura são disponibilizados como artefato da execução.
Um workflow separado realiza o *deploy* da versão web no GitHub Pages
sempre que há alterações na branch `main`.


## 🤝 Contributing & License

This is an academic project but pull-requests are welcome for educational purposes.
Code released under the **MIT License** – see [LICENSE](LICENSE).

---

> *“Gestão simples, cerveja gelada e boteco lotado.”* – **Boteco PRO**
