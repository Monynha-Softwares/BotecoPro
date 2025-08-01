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

## 📦 Ambiente de Desenvolvimento

1. Copie o arquivo `.env.example` para `.env` e preencha `SUPABASE_URL` e `SUPABASE_ANON_KEY` com as credenciais do seu projeto (as demais variáveis já possuem valores padrão para o Postgres local).
2. Certifique-se de ter o **Docker** instalado.
3. Inicie o banco local com:
   ```bash
   docker compose up -d
   ```
4. Aplique o esquema inicial executando `./scripts/init_postgres.sh` (use `--seed` caso queira gerar dados de exemplo). Caso prefira gerar esses dados ao iniciar o app, defina `CREATE_SAMPLE_DATA=true` no `.env`.
5. Execute o aplicativo normalmente com `flutter run`.
   Para rodar a versão web use `flutter run -d chrome`. Caso o navegador
   não esteja disponível (como em ambientes de CI ou containers
   minimalistas), utilize `flutter run -d web-server` para iniciar um
   servidor local.

## 🧪 Testes

Este repositório utiliza **Flutter Test** para validar os widgets e
funcionalidades principais do aplicativo. Os testes podem ser executados localmente
com o comando:

```bash
flutter test
```

Uma pipeline do **GitHub Actions** roda automaticamente em cada *push* e *pull request*,
executando `flutter analyze` e `flutter test` para garantir a qualidade do código.
Os relatórios de cobertura são disponibilizados como artefato da execução.
Um workflow separado realiza o *deploy* da versão web no GitHub Pages
sempre que há alterações na branch `main`.

---

## ⚙️ Deployment / Database setup

Para garantir que todas as tabelas utilizem **Row Level Security** em produção,
execute o script `supabase/tables/rls_policies.sql` no banco de dados do
Supabase.

1. Acesse o painel do projeto em <https://app.supabase.com/> e abra o SQL Editor
   (ou utilize o Supabase CLI).
2. Cole o conteúdo do arquivo e execute todas as instruções.
3. Verifique na aba **RLS Policies** de cada tabela que as políticas foram
   criadas corretamente.

Também é recomendável habilitar **Regional Replication** no painel do Supabase
(menu *Database › Replication*) para obter uma réplica de leitura em outra
região e reduzir a latência dos clientes.

Para otimizar as consultas mais comuns crie os seguintes índices manuais:

```sql
CREATE INDEX IF NOT EXISTS idx_produtos_user_nome ON produtos (user_id, nome);
CREATE INDEX IF NOT EXISTS idx_vendas_user_data ON vendas (user_id, data_venda DESC);
CREATE INDEX IF NOT EXISTS idx_pedidos_user_data ON pedidos (user_id, data_pedido DESC);
```

Com o Supabase CLI o mesmo pode ser feito via:

```bash
supabase db execute supabase/tables/rls_policies.sql
```


**Desenvolvido com ❤️ para a gestão de bares e restaurantes**

---


## 🤝 Contributing & License

This is an academic project but pull-requests are welcome for educational purposes.
Code released under the **MIT License** – see [LICENSE](LICENSE).

---

### 🙌 Acknowledgements

* Open-source Flutter community for awesome packages

---

> *“Gestão simples, cerveja gelada e boteco lotado.”* – **Boteco PRO**
