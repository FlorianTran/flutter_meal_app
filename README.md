# Meal App

A Flutter application for discovering and managing recipes using the [MealDB Free API](https://www.themealdb.com/api.php). Built with Clean Architecture principles and Riverpod for state management.

## Features

### Core Features
- 🏠 **Home Page**: Beautiful home screen with meal of the day, ingredient selection, and categories
- 📋 **Meal Catalog**: Browse all meals with advanced filtering and sorting
- 🔍 **Search**: Real-time search for meals by name
- 🥘 **Meal Details**: Complete recipe information with step-by-step instructions
- 🥗 **Ingredient Selection**: Select multiple ingredients to find matching recipes
- 📊 **Matching Meals**: Discover recipes you can make with selected ingredients
- 📝 **Ingredient Details**: View ingredient information and related meals
- ⭐ **Favorites**: Save your favorite meals locally
- 🏷️ **Categories**: Browse meals by category (country/area, seafood, etc.)

### Additional Features
- Image caching for better performance
- Offline support with local data caching
- Error handling and loading states
- Responsive design for different screen sizes
- Share functionality for recipes

## API

This app uses the **MealDB Free Public API**:
- **Base URL**: `https://www.themealdb.com/api/json/v1/{API_KEY}/`
- **Documentation**: https://www.themealdb.com/api.php
- **Test API Key**: Use `1` for development/educational use
- **Production**: Must become a supporter for app store releases
- **Contact**: thedatadb (at) gmail.com
- **Rate Limits**: Free tier - no authentication required, but limited to 100 items per query

### API Key Configuration
Store API key in `.env` file:
```
MEALDB_API_KEY=1
MEALDB_BASE_URL=https://www.themealdb.com/api/json/v1/
```

### Free API Endpoints Used
- `random.php` - Get random meal (Meal of the Day)
- `search.php?s={meal}` - Search meals by name
- `search.php?f={letter}` - Search meals by first letter
- `lookup.php?i={id}` - Get meal details by ID
- `categories.php` - List all meal categories (full objects)
- `list.php?c=list` - List all category names only
- `list.php?a=list` - List all area names only
- `list.php?i=list` - List all ingredient names only
- `filter.php?c={category}` - Filter by category
- `filter.php?a={area}` - Filter by area/country
- `filter.php?i={ingredient}` - Filter by single ingredient (note: free API only supports one ingredient)

### Premium API Endpoints (Requires Supporter Status)
- `randomselection.php` - Get 10 random meals
- `latest.php` - Get latest meals
- `filter.php?i={ing1},{ing2},{ing3}` - Multi-ingredient filter

### API Limitations (Free Tier)
- **100 Item Limit**: Free API returns max 100 items per query
- **Multi-Ingredient Filter**: Not available (single ingredient only)
- **Random Selection**: Only single random meal (not 10)
- **Latest Meals**: Not available

### Image URLs
- **Meal Images**: Add `/preview`, `/small`, `/medium`, or `/large` to image URL
- **Ingredient Images**: `https://www.themealdb.com/images/ingredients/{ingredient_name}.png`
  - Replace spaces with underscores (e.g., `chicken_breast.png`)
  - Available sizes: `-small.png`, `-medium.png`, `-large.png`

## Project Structure

Following Clean Architecture with feature-based organization:

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App widget configuration
├── core/                        # Core functionality
│   ├── constants/               # App constants
│   ├── di/                      # Dependency injection
│   ├── error/                   # Error handling
│   ├── network/                 # Network layer
│   ├── state_management/        # State management helpers
│   ├── theme/                   # App theme
│   └── utils/                   # Utilities
├── features/                    # Feature modules
│   ├── auth/                    # Authentication feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── meals/                   # Meals feature (to be implemented)
│       ├── data/
│       │   ├── datasources/     # API data sources
│       │   ├── models/          # Data models
│       │   └── repositories_impl/
│       ├── domain/
│       │   ├── entities/        # Business entities
│       │   ├── repositories/    # Repository interfaces
│       │   └── usecases/        # Business logic
│       └── presentation/
│           ├── notifier/        # Riverpod notifiers
│           ├── pages/           # Screen pages
│           └── widgets/         # UI widgets
└── shared/                      # Shared resources
    ├── extensions/
    ├── helpers/
    └── widgets/
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd flutter_meal_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. (Optional) Generate code for Riverpod annotations:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Running the App

**Option 1: Chrome (Web) - Recommended for quick development**
```bash
flutter run -d chrome
```

**Option 2: List available devices and choose**
```bash
flutter devices
flutter run -d <device_id>
```

### Hot Reload During Development

When the app is running, use these commands in the terminal:

- **r** - Hot reload (instantly see changes without losing state)
- **R** - Hot restart (full restart of the app)
- **h** - List all available interactive commands
- **d** - Detach (leave app running but exit flutter run)
- **c** - Clear the screen
- **q** - Quit (stop the application)

### Development Tips

- Follow Clean Architecture principles
- Use feature-based folder structure
- Keep business logic in domain layer
- Use Riverpod for state management
- Create reusable widgets in `shared/widgets/`
- Use Material Design 3 components
- Follow Flutter naming conventions

### Additional Useful Commands

```bash
# Build for production (Android)
flutter build apk

# Build for production (Web)
flutter build web

# Clean build artifacts
flutter clean

# Check for issues
flutter analyze

# Run tests
flutter test

# Generate code (Riverpod annotations)
flutter pub run build_runner watch

# View Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## Architecture

This project follows **Clean Architecture** principles:

- **Presentation Layer**: UI components, state management (Riverpod)
- **Domain Layer**: Business logic, entities, use cases, repository interfaces
- **Data Layer**: API clients, data models, repository implementations

### State Management

Using **Riverpod** for state management:
- `flutter_riverpod` for dependency injection and state management
- `riverpod_annotation` for code generation
- Feature-specific notifiers for each feature module

## Dependencies

### Core Dependencies
- `flutter_riverpod` - State management
- `riverpod_annotation` - Code generation
- `http` / `dio` - HTTP client for API calls
- `cached_network_image` - Image loading and caching
- `shared_preferences` / `hive` - Local storage
- `freezed` - Immutable models and union types

See `pubspec.yaml` for complete dependency list.

## Testing

### Unit Tests
- Repository implementations
- Use cases
- Utility functions
- State management logic

### Widget Tests
- Individual widgets
- Page components
- Navigation flows

### Integration Tests
- Complete user flows
- API integration
- State management flows

Run tests with:
```bash
flutter test
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev/)
- [MealDB API Documentation](https://www.themealdb.com/api.php)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
