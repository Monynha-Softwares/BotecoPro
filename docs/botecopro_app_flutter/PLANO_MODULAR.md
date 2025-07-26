# Plano de Implementação por Módulos

Este plano apresenta os módulos principais para evoluir o aplicativo **BotecoPro** em Flutter, priorizando o MVP integrado ao Supabase.

## 1. Setup e Integração com Supabase
- Adicionar o pacote `supabase_flutter` ao projeto.
- Armazenar `SUPABASE_URL` e `SUPABASE_ANON_KEY` em um arquivo `.env` (mantido fora do controle de versão).
- Inicializar o Supabase em `main.dart` criando um serviço dedicado para autenticação e acesso ao banco.

## 2. Módulo de Autenticação
- Implementar telas de login e cadastro (email/senha) utilizando o Supabase Auth.
- Gerenciar o estado de autenticação com Provider ou Riverpod (`AuthNotifier`).
- Proteger rotas de forma que usuários não autenticados sejam redirecionados para o login.

## 3. Produtos e Categorias
- Definir no Supabase as tabelas de produtos, categorias, ingredientes e opcionais.
- Adaptar os modelos Dart e substituir chamadas locais por queries ao Supabase.
- Construir a listagem de produtos com filtros por categoria e suporte a adicionais.

## 4. Carrinho / Comanda
- Criar um `CartProvider` ou `CartNotifier` para armazenar itens e quantidades.
- Permitir adicionar produtos com opcionais, alterar quantidade e remover itens.
- Persistir o pedido no Supabase ao confirmar a comanda.

## 5. Pedidos Ativos e Históricos
- Recuperar pedidos do Supabase utilizando assinaturas realtime para atualização de status.
- Fornecer telas distintas para garçom (controle de mesas) e cozinha (fila de preparo).
- Exibir alterações de status automaticamente conforme o pedido é atualizado.

## 6. Dashboard Operacional
- Consultar métricas de vendas do dia, mesas ocupadas e estoque baixo via Supabase.
- Apresentar os dados em cards ou gráficos adaptáveis a tablets.

## 7. Refatoração de Navegação
- Centralizar rotas nomeadas em um `RouteGenerator`.
- Manter um bottom navigation para as principais seções do app (Home, Mesas, Produtos, etc.).

## 8. Responsividade e Suporte a Tablets
- Utilizar `LayoutBuilder` e `MediaQuery` para adaptar grids e tamanhos de cards.
- Testar em diferentes resoluções garantindo boa usabilidade em modo paisagem e retrato.

