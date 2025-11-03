# Copilot Instructions · BotecoPro

Mental model: Flutter app to run a bar (tables, orders, products, recipes, internal production). Data is local-only (SharedPreferences via browser localStorage). Auth is handled by Clerk, but domain data persists client-side.

## Architecture in 12 lines
- Data: `lib/core/services/database_service.dart` is a singleton that owns all persistence. It defines storage keys (e.g., `_productsKey`, `_ordersKey`, `_salesKey`), JSON (de)serialization, and async CRUD like `getProducts`, `saveTables`, `addOrder`, `updateOrder`, `closeOrder`.
- Reactivity: `DatabaseService.changes` is a broadcast `Stream<void>`; pages listen and reload data on changes.
- Models: `lib/core/models/data_models.dart` with UUID ids, `copyWith`, `toJson/fromJson`, and enums with lowercase values. Key entities: Supplier, Product, TableModel, Order(+OrderItem), Recipe(+RecipeIngredient), InternalProduction(+ProductionIngredient), Sale.
- UI shape: Stateful pages in `lib/presentation/pages/` follow `initState → _loadData() → setState()` with `mounted` guard. Shared UI/formatting in `lib/presentation/widgets/` (see `shared_widgets.dart`).
- Navigation: Tabs come from `widgets/bottom_navigation.dart` (`NavigationTab`), with automatic `NavigationRail` on wide screens (`lib/main.dart`).
- Auth: Clerk integration gates entry (see `lib/core/services/auth_service.dart`, `lib/core/providers/auth_provider.dart`). After sign-in, the app uses only local data.
- Optional SQLite: `lib/core/providers/database_provider.dart` mirrors the `DatabaseService` API but isn’t wired by default; use only if migrating to large data/queries.

## Critical flows and invariants
- Seeding: First run seeds demo data via `HomePage._loadData()` → `DatabaseService.initializeData()`.
- Orders ↔ Tables ↔ Stock: `addOrder` sets `TableStatus.occupied` and links `currentOrderId`. `closeOrder` marks the order closed, decrements product stock per `OrderItem`, frees the table, and records a `Sale`. Keep these side-effects consistent when changing order logic.
- Formatting: Use BR locale with `intl ('pt_BR')`. Prefer `formatCurrency`, `formatDateTime`, `formatDate` from `presentation/widgets/shared_widgets.dart`.

## Conventions that differ from “typical” Flutter apps
- Never write to `SharedPreferences` directly from UI; always go through `DatabaseService` to preserve invariants and emit `changes`.
- Enums are lowercase in JSON; models must implement `toJson/fromJson/copyWith` and use UUIDs.
- Pages subscribe to `DatabaseService.instance.changes` to stay reactive (unsubscribe in `dispose`).

## How to extend safely
- New entity: (1) Add model + enum in `core/models/data_models.dart`; (2) Add storage key + CRUD in `core/services/database_service.dart`; (3) Create a page in `presentation/pages/*_page.dart` and wire a tab/route.
- Evolve order/payment flow: Update `closeOrder` and the `Sale` model side-effects together; verify table status and stock still reconcile.
- Switch to SQLite: Replace `DatabaseService` call sites with `DatabaseProvider()` and follow the init comment in `core/providers/database_provider.dart`.

## Developer workflow (Windows/PowerShell friendly)
- Run (web-first): `flutter pub get` → `flutter run -d web` (or `-d chrome`).
- Build: `flutter build web|apk|appbundle|ios` (web output in `build/web/`). Optional Docker: `Dockerfile` builds a static web image.
- Lint/format: `flutter analyze`; `dart format .`.
- Test: `flutter test` (see `test/` for structure). Smoke-test web build by serving `build/web/` locally.

## Pointers and examples
- Typical page pattern: see snippets in `AGENTS.md` (listen to `DatabaseService.changes`, call `getProducts()` in `_loadData()`).
- Key files to open first: `lib/main.dart`, `presentation/pages/home_page.dart`, `core/services/database_service.dart`, `core/models/data_models.dart`, `presentation/widgets/shared_widgets.dart`.
- Navigation enums and formatting utilities live under `lib/presentation/widgets/`.

If anything above is unclear (e.g., where to hook new order statuses, or whether to use SQLite vs SharedPreferences), say what’s missing and we’ll refine this guide.
# Copilot Instructions for BotecoPro

BotecoPro is a Flutter app to manage a bar (tables, orders, products, recipes, internal production) with local-only persistence; use this as your “mental model” to move fast in this codebase.

## Architecture in one glance
- Data lives client-side via SharedPreferences only (no backend). Models serialize to/from JSON. All keys are defined in `lib/core/services/database_service.dart` (e.g. `_productsKey`, `_ordersKey`, `_salesKey`).
- Persistence service: `DatabaseService` is a singleton (factory + private ctor). It exposes async CRUD like `getProducts`, `saveTables`, `updateOrder`, `closeOrder` and handles JSON encoding/decoding internally.
- Optional SQLite: `lib/core/providers/database_provider.dart` mirrors the same CRUD but isn’t wired by default. Use it only if migrating to large data/complex queries. Init example is documented in the file comments.
- Domain models live in `lib/core/models/data_models.dart` and use UUIDs, `copyWith()`, and enums (lowercase names). Core entities: Supplier, Product, TableModel, Order/OrderItem, Recipe/RecipeIngredient, InternalProduction/ProductionIngredient, Sale.
- UI uses stateful pages that load data in `initState()` → `_loadData()` → `setState()` with mounted checks. Shared widgets, formatting helpers, and bottom navigation are in `lib/presentation/widgets/`.

## Key flows and invariants (what to keep consistent)
- Seeding: `HomePage._loadData()` calls `DatabaseService.initializeData()` on first run to seed demo data (tables, products, suppliers, recipes, productions).
- Orders ↔ Tables: creating an order sets the table to `TableStatus.occupied` and links `currentOrderId` (`DatabaseService.addOrder`). Closing an order (`closeOrder`) marks it closed, decrements product stock for each `OrderItem`, frees the table, and appends a `Sale` record.
- Formatting/locale: All BR formatting via `intl` with `'pt_BR'`. Use `formatCurrency`, `formatDateTime`, `formatDate` from `presentation/widgets/shared_widgets.dart`.
- Navigation: Main tabs come from the `NavigationTab` enum in `widgets/bottom_navigation.dart`. On wide screens (`main.dart`) the layout switches to `NavigationRail` automatically.

## How to extend safely (examples from this repo)
- Add a new entity:
  1) Define model + enum in `core/models/data_models.dart` with `toJson/fromJson/copyWith`.
  2) Add a storage key and CRUD in `core/services/database_service.dart`.
  3) Create a page in `presentation/pages/*_page.dart` and wire a tab/route if user-facing.
- Evolve order flow: Respect the coupling with tables and inventory. If you add statuses or payment logic, also update `closeOrder` side effects and the `Sale` model.
- Switch to SQLite: Replace call sites of `DatabaseService` with `DatabaseProvider()` and follow the init instructions in `core/providers/database_provider.dart`.

## Developer workflow (verified)
- Run: `flutter pub get` → `flutter run` (web, mobile, or desktop). Web is the fastest path for iteration.
- Build: `flutter build web|apk|appbundle|ios`.
- Lint/format: `dart analyze`; `dart format .`.
- Useful entry points: `lib/main.dart`, `presentation/pages/home_page.dart`, `core/services/database_service.dart`, `core/models/data_models.dart`.

## Dependencies that matter here
- SharedPreferences (2.3.x) for persistence; uuid (3.x) for IDs; intl (pt_BR) for formatting; provider (prepared but optional); flutter_animate for subtle UI; fl_chart and table_calendar are used in UI; sqlite3 + path_provider exist for the optional SQLite provider.

## Tips for agents
- Prefer `DatabaseService` for data mutations to keep table/order/stock invariants intact.
- Use the shared formatting helpers and theme colors instead of hardcoding styles.
- Follow the page pattern: StatefulWidget → `_loadData()` → `setState()` with mounted guard.
- When adding navigation, update the `NavigationTab`/bottom navigation or use `Navigator.push` like in `suppliers_page.dart`.

If any section above is unclear (e.g., when to use SQLite vs SharedPreferences, or how `closeOrder` should evolve), tell us what you’re missing and we’ll refine this guide.
