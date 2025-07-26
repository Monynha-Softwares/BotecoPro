# Backlog Inicial – BotecoPro Flutter App

A tabela abaixo lista as issues sugeridas para desenvolver o MVP com Supabase.

| # | Título | Descrição | Prioridade | Dependências | Estimativa |
|---|-------|-----------|-----------|--------------|-----------|
| 1 | **AUTH \| Setup Supabase project keys** | Integração do SDK, variáveis `.env` e inicialização no `main()`. | MVP | - | 2 pts |
| 2 | **AUTH \| Tela de login e registro** | UI de login/registro, sessão persistente e logout. | MVP | #1 | 3 pts |
| 3 | **CORE \| Estruturar models no Supabase** | Migrar modelos de Produto e Categoria para tabelas Supabase e criar serviços. | MVP | #1 | 5 pts |
| 4 | **NAV \| Refatoração para rotas nomeadas** | Centralizar rotas em `RouteGenerator` e ajustar navegação. | MVP | #2 | 3 pts |
| 5 | **UI \| Listagem de produtos e categorias** | Exibir produtos e categorias vindos do Supabase em grid responsivo. | MVP | #3 | 5 pts |
| 6 | **CARRINHO \| Implementar comanda/carrinho** | Adicionar/remover produtos com opcionais e enviar pedido ao Supabase. | MVP | #5 | 5 pts |
| 7 | **PEDIDOS \| Realtime waiter & kitchen views** | Listar pedidos em tempo real para garçom e cozinha. | MVP | #6 | 8 pts |
| 8 | **DASH \| Dashboard operacional diário** | Mostrar métricas do dia e estoque baixo. | Nice-to-have | #7 | 5 pts |
| 9 | **RESPONSIVIDADE \| Ajustes gerais para tablets** | Revisar telas e grids para tablets. | Nice-to-have | #8 | 3 pts |

Responsáveis podem ser definidos pelo time conforme disponibilidade.
