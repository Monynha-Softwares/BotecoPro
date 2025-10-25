# Copilot Instructions for BotecoPro

BotecoPro is a Flutter bar management application for complete operations including tables, orders, products, recipes, and internal production tracking.

## Architecture Overview

### Data Persistence Pattern
- **Local Storage**: Uses `SharedPreferences` exclusively for all data (no backend/database server)
- **Serialization**: All models implement `toJson()` and `fromJson()` for SharedPreferences storage
- **Data Keys**: Each entity type has a static string key (`_suppliersKey`, `_productsKey`, etc.)
- **Singleton Service**: `DatabaseService` uses singleton pattern for app-wide access
- See: `lib/core/services/database_service.dart`

### Model Structure
- All data models are in `lib/core/models/data_models.dart`
- **Core Entities**: Supplier, Product, TableModel, Order, OrderItem, Recipe, InternalProduction
- **Enums**: TableStatus, OrderStatus, PaymentMethod, ProductCategory, RecipeType, ProductionStatus
- Each model uses `copyWith()` pattern for immutable updates with UUID generation for IDs
- See: `lib/core/models/data_models.dart`

### Page Architecture
- Each page is a StatefulWidget that loads data via `DatabaseService` in `initState()`
- Standard pattern: `Future<void> _loadData() async` → `setState()` with mounted check
- Bottom navigation controls main pages via enum: home, tables, products, recipes, production
- Authentication pages: login and signup for user management
- See: `lib/presentation/pages/`, `lib/presentation/widgets/bottom_navigation.dart`

### Theme & Localization
- **Colors**: Boteco-themed palette (wine `#8B1E3F`, mustard, beige, brown) defined in `theme.dart`
- **Locale**: Portuguese (Brazil) - `pt_BR` with `intl` package, set in `main.dart`
- **Material Design 3**: Enabled with custom ColorScheme and TextThemes
- See: `lib/theme.dart`, `lib/main.dart`

### Shared UI Components
- `CustomAppBar`: Consistent top navigation with optional back button and actions
- `MenuCard`: Reusable card widget for homepage sections
- Formatting helpers: `formatCurrency()`, `formatDateTime()`, `formatDate()`
- See: `lib/presentation/widgets/shared_widgets.dart`

## Key Dependencies
- **flutter_animate**: 4.0.0 - Page transitions and animations
- **provider**: 6.1.2 - State management
- **table_calendar**: 3.0.0 - Calendar widgets for date selection
- **fl_chart**: 0.68.0 - Chart rendering for analytics
- **shared_preferences**: 2.3.2 - Local data persistence
- **uuid**: 3.0.0 - ID generation
- **http**: 1.0.0 - HTTP requests
- **flutter_slidable**: 3.0.0 - Slidable list items

## Developer Workflows

### Running the App
```bash
flutter pub get
flutter run
```

### Building for Platforms
- **Android**: `flutter build apk` or `flutter build appbundle`
- **iOS**: `flutter build ios` or `flutter build ipa`
- **Web**: `flutter build web`

### Code Formatting & Analysis
- `dart format .` - Format all Dart files
- `dart analyze` - Check for lint issues per `analysis_options.yaml`

## Important Patterns & Conventions

### StatefulWidget Initialization Pattern
```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  // Load data
  if (mounted) {
    setState(() {
      // Update state
    });
  }
}
```

### Database Service CRUD
- All CRUD methods are async: `getTables()`, `saveProducts()`, `deleteOrder()`, etc.
- Returns deserialized model instances (not JSON)
- Handles list serialization via json encoding/decoding internally
- See patterns at top of `database_service.dart` for each entity

### Naming Conventions
- Private properties: `_privateVar` (underscore prefix)
- Enum values lowercase: `TableStatus.free`
- Service methods: verb-based (`getTables`, `saveTables`, `deleteTable`)
- Pages: `*_page.dart` (e.g., `home_page.dart`)
- Models: singular nouns (`Product`, `TableModel`, `Order`)

### Colors in UI
Always use theme colors for consistency:
- `Theme.of(context).colorScheme.primary` (wine - primary actions)
- `Theme.of(context).colorScheme.secondary` (mustard - accents)
- `Theme.of(context).colorScheme.surface` (light background)

### LocalDateTime Handling
- All dates formatted with `intl` package using `'pt_BR'` locale
- Format helpers exist in `shared_widgets.dart` - reuse them
- Server timestamps would need conversion (currently local-only)

## Common Tasks

### Adding a New Entity Type
1. Add enum/model class to `lib/core/models/data_models.dart`
2. Add `toJson()`/`fromJson()` and `copyWith()` methods
3. Add storage key and CRUD methods to `DatabaseService`
4. Create corresponding page in `lib/presentation/pages/*_page.dart`
5. Add navigation tab and bottom_navigation item if user-facing

### Modifying Order Flow
- Orders are tightly coupled to tables via `currentOrderId`
- OrderItems track individual product status changes
- Production planning references recipes and products
- Always update both order and table state consistently

### Creating a New Page
- Extend `StatefulWidget` with corresponding `State` class
- Inject `DatabaseService` in `initState()`
- Use `CustomAppBar` for consistency
- End with bottom navigation integration and route addition

## File Structure Summary
```
lib/
├── main.dart
├── theme.dart
├── core/
│   ├── device/
│   │   ├── app.db
│   │   └── configs.json
│   ├── models/
│   │   └── data_models.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── database_provider.dart
│   └── services/
│       ├── auth_service.dart
│       └── database_service.dart
└── presentation/
    ├── pages/
    │   ├── home_page.dart
    │   ├── login_page.dart
    │   ├── signup_page.dart
    │   ├── order_details_page.dart
    │   ├── production_page.dart
    │   ├── products_page.dart
    │   ├── recipes_page.dart
    │   ├── suppliers_page.dart
    │   └── tables_page.dart
    └── widgets/
        ├── bottom_navigation.dart
        └── shared_widgets.dart
```

## Notes for Future Development
- **Backend Integration**: Consider a backend service for multi-user sync and data backup.
- **Analytics**: No logging/analytics service yet (charts only for UI display)
- **Testing**: No test files currently - consider unit tests for DatabaseService and models
