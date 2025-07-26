# BotecoPro Flutter App – Plano de Implementação

Este plano resume os módulos principais para construir o MVP do app BotecoPro usando Flutter 3.x e Supabase.

## 1. Setup Inicial e Integração Supabase
- Adicionar `supabase_flutter` ao `pubspec.yaml`.
- Criar arquivo `.env` para guardar `SUPABASE_URL` e `SUPABASE_ANON_KEY` (não versionar).
- Inicializar o Supabase no `main()` e criar um `SupabaseService` para chamadas de Auth e DB.

## 2. Módulo de Autenticação
- Tela de login/registro usando Supabase Auth (e-mail/senha).
- Gerenciar estado de autenticação com Provider ou Riverpod (`AuthNotifier`).
- Proteger rotas: redirecionar usuários não autenticados para a tela de login.

## 3. Produtos e Categorias
- Definir tabelas no Supabase para produtos, categorias, ingredientes e opcionais.
- Criar modelos e serviços que consultem o Supabase em vez de storage local.
- Listar produtos filtrando por categoria com layout responsivo.

## 4. Carrinho / Comanda
- Implementar `CartProvider` (ou `CartNotifier`) para itens e quantidades.
- Permitir adicionar/remover produtos com opcionais.
- Persistir o pedido no Supabase ao confirmar.

## 5. Pedidos (Realtime)
- Buscar pedidos ativos e históricos via Supabase.
- Assinar atualizações em tempo real para mudanças de status.
- Telas separadas para garçom e cozinha.

## 6. Dashboard Operacional
- Consultar métricas do dia (vendas, mesas ocupadas, estoque baixo).
- Apresentar cards/gráficos adaptáveis em tablets.

## 7. Refatoração de Navegação
- Implementar navegação por rotas nomeadas com `RouteGenerator`.
- Manter `BottomNavigationBar` para seções principais.

## 8. Responsividade
- Revisar todas as telas com `LayoutBuilder` e `MediaQuery`.
- Garantir bom funcionamento em tablets (paisagem e retrato).

Este plano modular orienta a evolução do app rumo ao MVP integrado com Supabase, mantendo foco em autenticação, pedidos e experiência de garçom/cozinha.
