
Refatore a arquitetura atual da branch:

`copilot/odoo-integration`

do repositório:

`https://github.com/marcelo-m7/BotecoPRO`

para adotar uma estratégia muito mais simples para o MVP.

# Nova decisão arquitetural

O BotecoPRO MVP terá apenas dois componentes principais:

```text
Flutter App
    │
    │ HTTPS
    │ utilizador + API key
    ▼
Odoo Online
```

O aplicativo Flutter deverá comunicar-se **diretamente com a API do Odoo**.

Não deverá existir, nesta fase:

* backend BotecoPRO intermediário;
* REST API própria em `botecopro_api`;
* gateway;
* Supabase;
* serviço de autenticação próprio;
* servidor middleware;
* camada OpenAPI separada;
* duplicação dos dados do Odoo noutro backend.

O objetivo é reduzir drasticamente a complexidade e chegar rapidamente a um MVP utilizável.

---

# Princípio central

**Odoo é o backend do BotecoPRO.**

O Flutter é essencialmente um cliente especializado para restauração, oferecendo uma UX própria sobre os dados e processos existentes no Odoo.

Sempre que possível:

```text
Flutter UI
      ↓
Flutter repository/service
      ↓
Odoo API
      ↓
Odoo standard models
```

Não devemos recriar no BotecoPRO aquilo que já existe no Odoo.

---

# Autenticação do MVP

Na primeira versão, o utilizador deverá configurar no app:

```text
URL da instância Odoo
Base de dados, caso necessária
Utilizador / login
API Key
```

Exemplo conceitual:

```text
Instance:
https://empresa.odoo.com

User:
manager@empresa.pt

API Key:
••••••••••••••••
```

A API key deverá funcionar como credencial do próprio utilizador.

Consequentemente:

* cada request é executado no contexto daquele utilizador;
* as permissões continuam controladas pelo Odoo;
* ACLs e record rules do Odoo devem ser respeitadas;
* o BotecoPRO não deverá implementar um segundo sistema de permissões.

---

# Segurança

A API key nunca poderá:

* ser colocada no código;
* estar num `.env` versionado;
* aparecer em logs;
* ser enviada para analytics;
* ficar armazenada em texto simples.

No Flutter utilize armazenamento seguro apropriado da plataforma, por exemplo:

```text
flutter_secure_storage
```

ou solução equivalente.

A configuração de conexão poderá conter:

```text
OdooConnection
├── baseUrl
├── database
├── login
└── apiKey
```

Porém a API key deverá ser obtida exclusivamente do secure storage.

---

# Odoo Client

Crie uma camada central reutilizável no Flutter.

Estrutura candidata:

```text
lib/
├── core/
│   └── odoo/
│       ├── odoo_client.dart
│       ├── odoo_auth.dart
│       ├── odoo_connection.dart
│       ├── odoo_exception.dart
│       └── odoo_session.dart
│
├── features/
│   ├── products/
│   ├── customers/
│   ├── pos/
│   ├── orders/
│   └── settings/
│
└── ...
```

Não acople widgets diretamente a chamadas RPC.

Fluxo desejado:

```text
Widget
 ↓
Controller / Provider
 ↓
Repository
 ↓
OdooClient
 ↓
Odoo
```

---

# API Odoo

Antes de implementar, confirme qual interface oficial e suportada pela versão alvo do Odoo deverá ser utilizada para comunicação externa.

Preferir APIs standard do Odoo.

Encapsule todos os detalhes RPC/API dentro de:

```text
OdooClient
```

O restante aplicativo não deverá conhecer detalhes como:

* endpoints internos;
* payload RPC;
* autenticação HTTP;
* formato bruto das respostas Odoo.

Exemplo conceitual:

```dart
final products = await odoo.products.search(
  domain: [
    ['sale_ok', '=', true]
  ],
);
```

em vez de espalhar chamadas RPC pelo código.

---

# Não criar `botecopro_api`

A arquitetura atual possui:

```text
addons/botecopro_api
```

com uma REST API BotecoPRO própria.

Essa decisão deve ser revertida para o MVP.

Audite todo o conteúdo relacionado a:

```text
botecopro_api
packages/api_contracts
docs/api
OpenAPI
/api/v1/...
```

Classifique cada elemento entre:

```text
REMOVE
REFACTOR
KEEP FOR FUTURE
```

Não deixe código morto simulando uma arquitetura que não será utilizada.

Se houver documentação útil, mova-a para:

```text
docs/archive/
```

ou atualize-a para representar a nova arquitetura.

---

# Addons Odoo

Também não devemos criar addons apenas porque o BotecoPRO existe.

Comece utilizando exclusivamente os modelos standard do Odoo sempre que possível.

Por exemplo:

```text
Clientes
→ res.partner

Produtos
→ product.template
→ product.product

Categorias
→ product.category
→ pos.category

Pedidos POS
→ pos.order
→ pos.order.line

Sessões POS
→ pos.session

Funcionários
→ hr.employee

Stock
→ stock.quant
→ stock.move

Empresas
→ res.company
```

Um addon `botecopro_core` só deve continuar existindo se houver necessidades de domínio que realmente não possam ser representadas pelo Odoo standard.

Faça uma auditoria desse addon e identifique quais modelos/campos podem ser eliminados em favor de funcionalidades nativas.

Princípio:

**Odoo Standard First.**

---

# Sincronização

O aplicativo deverá conversar diretamente com o Odoo.

Para o primeiro MVP, não tente construir imediatamente uma engine complexa de sync distribuído.

Comece simples:

```text
Abrir app
   ↓
validar credenciais
   ↓
carregar dados essenciais
   ↓
cache local
   ↓
utilização
   ↓
enviar alterações ao Odoo
```

Implemente uma abstração que permita evoluir depois.

Exemplo:

```text
SyncService
├── syncProducts()
├── syncCustomers()
├── syncOrders()
└── syncConfiguration()
```

A fonte de verdade permanece:

```text
Odoo
```

O cache Flutter existe para:

* performance;
* experiência mobile;
* funcionamento temporário com conectividade limitada.

Não deve transformar-se num segundo backend.

---

# Offline

Offline completo não é requisito da primeira versão.

O MVP pode inicialmente exigir internet para:

* autenticação;
* criação definitiva de operações;
* sincronização.

Entretanto, mantenha a arquitetura preparada para posteriormente adicionar:

```text
Local cache
+
Outbox
+
Retry queue
+
Conflict handling
```

Não implemente agora uma infraestrutura complexa sem necessidade.

Prioridade:

```text
funcionar corretamente online
>
cache local
>
offline avançado
```

---

# Primeiro onboarding

Crie ou planeje uma experiência simples de conexão.

## Tela 1 — Conectar ao Odoo

Campos:

```text
URL da instância
Utilizador
API Key
```

Adicionar:

```text
[Testar conexão]
```

Ao testar:

1. verificar conectividade;
2. autenticar;
3. identificar o utilizador;
4. identificar a empresa;
5. validar acesso aos modelos necessários;
6. apresentar sucesso ou erro compreensível.

Depois:

```text
[Entrar no BotecoPRO]
```

---

# Multiempresa

A arquitetura deverá respeitar multi-company do Odoo.

Depois da autenticação, obter:

```text
res.users
allowed_company_ids
company_id
```

Se o utilizador tiver várias empresas, futuramente permitir seleção.

Não inventar um sistema separado de tenants.

```text
BotecoPRO tenant
=
Odoo company
```

sempre que essa correspondência fizer sentido.

---

# Odoo Online

A solução deverá ser pensada prioritariamente para utilização com:

```text
*.odoo.com
```

O objetivo do BotecoPRO é permitir que estabelecimentos que utilizem Odoo possam utilizar o aplicativo como uma interface mobile/POS especializada.

Portanto, evite dependências arquiteturais que exijam:

* acesso ao filesystem do servidor;
* módulos Python customizados obrigatórios;
* Odoo.sh;
* servidor próprio;
* reverse proxy específico.

O MVP deverá buscar a máxima compatibilidade possível com **Odoo Online standard**.

---

# Evolução futura — Portal users

Existe uma segunda fase importante, mas ela NÃO deve ser implementada agora.

No futuro queremos permitir que:

```text
Portal User Odoo
     ↓
BotecoPRO / página de configuração
     ↓
Gerar ou associar API Key
     ↓
App BotecoPRO
```

A ideia é permitir que utilizadores com acesso apropriado através do portal/Odoo possam provisionar a integração do BotecoPRO com menos fricção.

Essa funcionalidade futura poderá envolver:

* página no portal;
* onboarding BotecoPRO;
* geração/revogação de credenciais;
* QR code de configuração;
* deep link para o aplicativo;
* associação entre dispositivo e utilizador;
* gestão de dispositivos autorizados.

Documente como:

```text
docs/roadmap/portal-api-key-provisioning.md
```

mas **não implemente nesta fase**.

---

# Visão futura do onboarding

A experiência futura poderá tornar-se:

```text
Odoo
 ↓
Portal BotecoPRO
 ↓
"Adicionar dispositivo"
 ↓
QR Code / deep link
 ↓
Flutter BotecoPRO
 ↓
credenciais armazenadas com segurança
```

Assim o utilizador não precisará copiar manualmente URLs e API keys.

Mas o MVP deverá começar com entrada manual.

---

# Arquitetura alvo do MVP

Atualize toda a documentação para representar:

```text
┌─────────────────────┐
│   BotecoPRO Flutter │
│                     │
│ UI                  │
│ repositories        │
│ local cache         │
│ secure storage      │
└──────────┬──────────┘
           │
           │ HTTPS
           │ user + API key
           ▼
┌─────────────────────┐
│     Odoo Online     │
│                     │
│ Contacts            │
│ Products            │
│ POS                 │
│ Sales               │
│ Inventory           │
│ Accounting          │
│ Users / ACLs        │
└─────────────────────┘
```

Sem camada intermediária.

---

# Refatoração do repositório

A estrutura atual possui `addons`, `packages/api_contracts`, infraestrutura Docker e documentação de uma API REST própria.

Simplifique onde possível.

Estrutura alvo aproximada:

```text
BotecoPRO/
├── apps/
│   ├── mobile/
│   └── website/
│
├── addons/
│   └── [somente addons realmente necessários]
│
├── docs/
│   ├── architecture/
│   ├── development/
│   ├── migration/
│   └── roadmap/
│
├── scripts/
│
├── .github/
├── AGENTS.md
└── README.md
```

`packages/api_contracts` não deve existir apenas para representar uma REST API que deixou de existir.

`infrastructure/docker` pode continuar disponível para desenvolvimento/testes locais de Odoo, mas não deve ser descrita como requisito de produção.

---

# README

Atualize o README.

A definição da stack deve passar de algo equivalente a:

```text
Flutter
↓
BotecoPRO REST API
↓
Odoo
```

para:

```text
Flutter
↓
Odoo API
↓
Odoo Online
```

Deixar explícito:

**BotecoPRO não é um ERP paralelo ao Odoo.**

BotecoPRO é uma experiência especializada para restauração construída sobre Odoo.

---

# MVP inicial

Defina como primeira vertical funcional:

### 1. Connection

* URL;
* utilizador;
* API key;
* testar conexão;
* secure storage.

### 2. Bootstrap

Após login carregar:

* utilizador atual;
* empresa;
* configurações;
* POS disponível;
* categorias essenciais.

### 3. Products

Consultar produtos disponíveis para venda.

### 4. Customers

Pesquisar/criar clientes quando permitido.

### 5. POS / Orders

Começar integração com os modelos standard do Odoo POS.

Faça primeiro leitura e mapeamento.

Não implemente writes perigosos sem compreender:

```text
pos.config
pos.session
pos.order
pos.order.line
payment methods
stock moves
accounting consequences
```

---

# Auditoria antes de modificar

Antes de escrever código:

1. audite a branch inteira;
2. identifique tudo que depende da antiga arquitetura REST;
3. identifique código já existente no Flutter relacionado ao Odoo;
4. identifique duplicações entre Flutter e addons;
5. produza um pequeno plano de refatoração.

Depois execute-o incrementalmente.

Não mantenha compatibilidade artificial com a antiga arquitetura se ela ainda não está em produção.

Estamos deliberadamente mudando a arquitetura enquanto o projeto ainda está em fase inicial.

---

# Commits

Faça alterações incrementais usando Conventional Commits.

Exemplo:

```text
docs(architecture): simplify MVP to direct Odoo integration

refactor(api): remove BotecoPRO intermediary REST layer

refactor(mobile): introduce direct Odoo client

feat(mobile): add Odoo API key connection model

feat(mobile): add secure credential storage

feat(mobile): add Odoo connection onboarding

docs(roadmap): document portal API key provisioning
```

Não concentre toda a refatoração num único commit.

---

# Critérios de conclusão

Ao terminar quero:

1. arquitetura antiga removida ou claramente arquivada;
2. README refletindo Flutter → Odoo direto;
3. documentação coerente;
4. `botecopro_api` removido se não houver necessidade concreta;
5. Flutter com uma camada `OdooClient`;
6. configuração por URL + user + API key;
7. API key em secure storage;
8. função de teste de conexão;
9. pelo menos uma consulta real read-only ao Odoo;
10. testes unitários para autenticação/configuração/client;
11. `flutter analyze` sem novos erros;
12. roadmap documentando o futuro provisionamento de API keys via portal;
13. relatório final das alterações, limitações encontradas e próximos passos.

## Regra principal

Sempre escolher a alternativa mais simples que permita entregar o MVP:

**Flutter + Odoo Online + API nativa + API key do utilizador.**

Não introduza middleware, microserviços ou addons customizados sem uma necessidade funcional concreta.
