# Meal App Development Plan

## Overview
A Flutter application for discovering and managing recipes using the [MealDB Free API](https://www.themealdb.com/api.php). The app follows Clean Architecture principles with Riverpod for state management.

## API Information
- **Base URL**: `https://www.themealdb.com/api/json/v1/{API_KEY}/`
- **Documentation**: https://www.themealdb.com/api.php
- **Test API Key**: Use `1` for development/educational use
- **Production**: Must become a supporter for app store releases
- **Contact**: thedatadb (at) gmail.com
- **Rate Limits**: Free tier - no authentication required, but limited to 100 items per query

### API Key Management
- **Development**: Use test key `1` in URL: `https://www.themealdb.com/api/json/v1/1/`
- **Production**: Requires supporter status (PayPal signup)
- **Premium Features**: Multi-ingredient filter, random selection (10 meals), latest meals, full database access
- **Configuration**: Store API key in `.env` file or environment variables

### Free API Endpoints
- `search.php?s={meal}` - Search meals by name
  - Example: `search.php?s=Arrabiata`
- `search.php?f={letter}` - List all meals by first letter
  - Example: `search.php?f=a`
- `lookup.php?i={id}` - Lookup full meal details by ID
  - Example: `lookup.php?i=52772`
- `random.php` - Lookup a single random meal (Meal of the Day)
- `categories.php` - List all meal categories (returns full category objects)
- `list.php?c=list` - List all category names only
- `list.php?a=list` - List all area names only
- `list.php?i=list` - List all ingredient names only
- `filter.php?i={ingredient}` - Filter by main ingredient (single ingredient only)
  - Example: `filter.php?i=chicken_breast`
  - Note: Use underscores for spaces in ingredient names
- `filter.php?c={category}` - Filter by category
  - Example: `filter.php?c=Seafood`
- `filter.php?a={area}` - Filter by area/country
  - Example: `filter.php?a=Canadian`

### Premium API Endpoints (Requires Supporter Status)
- `randomselection.php` - Lookup a selection of 10 random meals
- `latest.php` - Get latest meals
- `filter.php?i={ing1},{ing2},{ing3}` - Multi-ingredient filter
  - Example: `filter.php?i=chicken_breast,garlic,salt`
  - Note: Free API is limited to single ingredient filter

### API Limitations (Free Tier)
- **List Limit**: Limited to 100 items per query
- **Multi-Ingredient Filter**: Not available (single ingredient only)
- **Random Selection**: Only single random meal (not 10)
- **Latest Meals**: Not available
- **Full Database**: Limited access

### Image URLs

#### Meal Images
- **Base URL**: `https://www.themealdb.com/images/media/meals/{image_filename}`
- **Thumbnail Sizes**:
  - Small: Add `/preview` or use `/small` at end of URL
  - Medium: Add `/medium` at end of URL
  - Large: Add `/large` at end of URL
- **Example**: 
  - Original: `https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg`
  - Small: `https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg/preview`
  - Medium: `https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg/medium`
  - Large: `https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg/large`

#### Ingredient Images
- **Base URL**: `https://www.themealdb.com/images/ingredients/{ingredient_name}.png`
- **Naming**: Replace spaces with underscores in ingredient name
- **Sizes Available**:
  - Default: `{ingredient_name}.png`
  - Small: `{ingredient_name}-small.png`
  - Medium: `{ingredient_name}-medium.png`
  - Large: `{ingredient_name}-large.png`
- **Examples**:
  - `https://www.themealdb.com/images/ingredients/lime.png`
  - `https://www.themealdb.com/images/ingredients/lime-small.png`
  - `https://www.themealdb.com/images/ingredients/lime-medium.png`
  - `https://www.themealdb.com/images/ingredients/lime-large.png`
  - `https://www.themealdb.com/images/ingredients/chicken_breast.png` (with underscore)

## Architecture
Following Clean Architecture with feature-based organization:
```
features/
  └── meals/
      ├── data/
      │   ├── datasources/
      │   ├── models/
      │   └── repositories_impl/
      ├── domain/
      │   ├── entities/
      │   ├── repositories/
      │   └── usecases/
      └── presentation/
          ├── notifier/
          ├── pages/
          └── widgets/
```

## Features & Pages

### 1. Home Page (`home_page.dart`)
**Design**: Based on Figma screenshot provided

**Components**:
- Header: "Find your next meal" title
- **Meal of the Day Section**:
  - Subtitle: "Meal of day"
  - Featured meal card with image
  - Meal name overlay with ingredient count
  - Star icon (favorite indicator)
  - Tap to navigate to meal details
- **Ingredient Selection Section**:
  - Description text: "We'll suggest recipes that match what you have."
  - "Select ingredients" button → navigates to ingredients page
- **Categories Section**:
  - Subtitle: "Categories" with arrow icon
  - Horizontal scrollable list of category cards
  - Each card: circular icon + label
  - Tap category → navigates to meal list filtered by category
- **Recently Viewed Section** (Optional):
  - Subtitle: "Recently Viewed" with "See All" link
  - Horizontal scrollable list of recently viewed meal cards
  - Each card shows thumbnail and meal name
  - Tap card → navigate to meal details
  - "See All" → navigate to Recently Viewed Page
- **Bottom Navigation**:
  - Pill-shaped bar with home icon (active), favorites icon, and list icon (catalog)

**State Management**:
- `HomeNotifier` - manages meal of the day, categories, featured meals
- `MealOfDayNotifier` - fetches random meal daily

**API Calls**:
- `random.php` - Get meal of the day (single random meal)
- `categories.php` - Get all meal categories (full category objects with images)
- `list.php?c=list` - Get all category names (lightweight list)
- `list.php?a=list` - Get all area names (for area filtering)

---

### 2. Meal Catalog/List Page (`meal_catalog_page.dart`)
**Purpose**: Display all available meals with filtering and sorting options

**Features**:
- **Search Bar**: Real-time search by meal name
- **Filter Options**:
  - By Category (dropdown/chips)
  - By Area/Country (dropdown/chips)
  - By Ingredient (multi-select)
  - By Dietary Restrictions (multi-select chips):
    - Vegetarian, Vegan, Gluten-Free, Dairy-Free
    - Keto, Paleo, Low-Carb, Halal, Kosher
  - Favorites filter toggle
  - Recently viewed filter toggle
- **Sort Options**:
  - Alphabetical (A-Z, Z-A)
  - By popularity (if available)
  - Recently added
- **Display**:
  - Grid or list view toggle
  - Meal cards with:
    - Thumbnail image
    - Meal name
    - Category/Area tags
    - Favorite icon
    - Ingredient count
- **Pagination/Infinite Scroll**: Load meals in batches
- **Empty States**: No results, loading, error states

**State Management**:
- `MealCatalogNotifier` - manages meal list, filters, sorting
- `MealSearchNotifier` - handles search functionality

**API Calls**:
- `search.php?s={query}` - Search meals by name
- `search.php?f={letter}` - Search meals by first letter (for alphabetical browsing)
- `filter.php?c={category}` - Filter by category
- `filter.php?a={area}` - Filter by area/country
- `filter.php?i={ingredient}` - Filter by single ingredient (note: free API only supports one ingredient)
- `categories.php` - Get all categories for filter dropdown
- `list.php?c=list` - Get category names for filter chips
- `list.php?a=list` - Get area names for filter dropdown
- **Note**: Free API limited to 100 results per query - implement pagination if needed

---

### 3. Ingredients Selection Page (`ingredients_selection_page.dart`)
**Purpose**: Allow users to select multiple ingredients and find matching recipes

**Features**:
- **Ingredient List**:
  - Grid/list of ingredient cards
  - Each card displays:
    - Ingredient image (from API)
    - Ingredient name
    - Selection indicator (checkbox/overlay)
  - Long-press on ingredient → opens ingredient details page
- **Selection UI**:
  - Visual feedback on selected ingredients
  - Selected count badge
- **Bottom Action Bar** (sticky):
  - Shows: "X ingredients selected"
  - Shows: "Y meals available" (count of matching meals)
  - Arrow button → navigates to matching meals page
  - Disabled when no ingredients selected
- **Search/Filter**: Search ingredients by name
- **Categories**: Optional grouping by ingredient type

**State Management**:
- `IngredientsSelectionNotifier` - manages selected ingredients
- `MatchingMealsNotifier` - calculates matching meals based on selected ingredients

**API Calls**:
- `list.php?i=list` - Get all ingredient names
- `filter.php?i={ingredient}` - Get meals for each selected ingredient (single ingredient per call)
  - Note: Free API only supports single ingredient filter
  - For multiple ingredients: Make separate API calls for each ingredient and combine results locally

**Logic**:
- When ingredients selected → find meals that contain ALL selected ingredients (intersection)
- **Free API Limitation**: Cannot use multi-ingredient filter endpoint
- **Workaround**: 
  1. Make separate API calls for each selected ingredient
  2. Combine results locally to find intersection (meals containing all selected ingredients)
  3. Cache results to avoid repeated API calls
- Display count of matching meals in real-time
- Optimize: Cache meal-ingredient mappings locally
- **Ingredient Image URLs**: Use `https://www.themealdb.com/images/ingredients/{ingredient_name}.png` (replace spaces with underscores)

---

### 4. Matching Meals Page (`matching_meals_page.dart`)
**Purpose**: Display meals that can be made with selected ingredients

**Features**:
- **Header**: "Meals you can make" with ingredient count
- **Meal List**:
  - Similar to catalog page but filtered
  - Show which selected ingredients are in each meal
  - Highlight matching ingredients
- **Meal Cards**:
  - Thumbnail, name, category
  - "X of Y ingredients available" indicator
  - Tap → navigate to meal details
- **Empty State**: "No meals found with selected ingredients"
- **Reset Button**: Clear selection and go back

**State Management**:
- `MatchingMealsNotifier` - manages filtered meal list based on selected ingredients

**API Calls**:
- `filter.php?i={ingredient}` - For each selected ingredient (single ingredient per call)
- **Free API Limitation**: Multi-ingredient filter not available
- **Implementation**:
  1. Make separate API calls for each selected ingredient
  2. Combine results locally to find intersection (meals containing all ingredients)
  3. Display matching meals sorted by ingredient match count
- Cache results to minimize API calls

---

### 5. Meal Details Page (`meal_details_page.dart`)
**Purpose**: Show complete recipe information with instructions

**Features**:
- **Header**:
  - Back button
  - Meal image (large)
  - Favorite button (star icon)
  - Share button
- **Content Sections**:
  - Meal name (large, bold)
  - Category and Area tags
  - **Ingredients List**:
    - List of ingredients with measurements
    - Optional: highlight if ingredient is in user's selection
  - **Instructions**:
    - Step-by-step numbered instructions
    - Formatted for readability
  - **YouTube Video** (if available):
    - Embedded video player or link
  - **Source Link** (if available):
    - External link to original recipe
  - **Similar Meals Section**:
    - "You might also like" title
    - Horizontal scrollable list of similar meal cards
    - Each card shows thumbnail, name, and similarity indicator
    - Tap card → navigate to meal details
    - "View All Similar Meals" button → navigate to Similar Meals Page
  - **Actions**:
  - "Add to Favorites" / "Remove from Favorites"
  - "Share Recipe"
  - "View Similar Meals" → navigate to Similar Meals Page

**State Management**:
- `MealDetailsNotifier` - manages meal details, favorite status
- `FavoritesNotifier` - manages favorites list (local storage)

**API Calls**:
- `lookup.php?i={id}` - Get full meal details

**Storage**:
- Favorites saved locally (SharedPreferences or Hive)

---

### 6. Ingredient Details Page (`ingredient_details_page.dart`)
**Purpose**: Show ingredient information and related meals

**Features**:
- **Header**:
  - Ingredient image (large)
  - Ingredient name
  - Back button
- **Content Sections**:
  - **Description** (if available from API):
    - Ingredient information, usage, etc.
  - **Meals Using This Ingredient**:
    - Grid/list of meal cards
    - Each shows meal thumbnail and name
    - Tap → navigate to meal details
- **Actions**:
  - "Add to Selection" button (if accessed from ingredients page)
  - "View All Meals" → navigate to filtered catalog

**State Management**:
- `IngredientDetailsNotifier` - manages ingredient details and related meals

**API Calls**:
- `filter.php?i={ingredient}` - Get meals using this ingredient
  - Note: Replace spaces with underscores in ingredient name (e.g., `chicken_breast`)
- `search.php?s={ingredient}` - Alternative search (may return meals with ingredient in name)
- **Ingredient Image**: `https://www.themealdb.com/images/ingredients/{ingredient_name}.png`
  - Replace spaces with underscores (e.g., `chicken_breast.png`)
  - Available sizes: `-small.png`, `-medium.png`, `-large.png`

---

### 7. Categories Page (Optional - `categories_page.dart`)
**Purpose**: Browse meals by category or area

**Features**:
- Grid of category cards
- Each category shows:
  - Icon/image
  - Category name
  - Meal count
- Tap category → navigate to filtered catalog

---

### 8. Favorites Page (`favorites_page.dart`)
**Purpose**: Display all favorited meals in a dedicated page

**Features**:
- **Header**:
  - Title: "My Favorites"
  - Favorite count badge
  - Search bar (search within favorites)
- **Content**:
  - Grid/list view toggle
  - Meal cards with:
    - Thumbnail image
    - Meal name
    - Category/Area tags
    - Favorite icon (active)
    - Remove from favorites button
  - Empty state: "No favorites yet" with call-to-action
- **Filter Options**:
  - Filter by category
  - Filter by area
  - Sort by: date added, name, category
- **Actions**:
  - Remove from favorites (swipe to delete)
  - Clear all favorites (with confirmation)
  - Share favorite meals

**State Management**:
- `FavoritesNotifier` - manages favorites list
- Loads from local storage on page load

**Navigation**:
- Accessible from bottom navigation (favorites icon)
- Accessible from home page
- Accessible from meal details page

---

### 9. Recently Viewed Page (`recently_viewed_page.dart`)
**Purpose**: Display recently viewed meals

**Features**:
- **Header**:
  - Title: "Recently Viewed"
  - Clear history button
- **Content**:
  - List of recently viewed meals (most recent first)
  - Each item shows:
    - Thumbnail image
    - Meal name
    - View timestamp (e.g., "2 hours ago")
    - Category/Area tags
    - Quick access to meal details
  - Empty state: "No recently viewed meals"
- **Actions**:
  - Remove from history (swipe to delete)
  - Clear all history (with confirmation)
  - View meal details

**State Management**:
- `RecentlyViewedNotifier` - manages recently viewed list
- Auto-updates when meals are viewed

**Navigation**:
- Accessible from navigation drawer
- Accessible from home page (optional section)
- Auto-navigates from meal details after viewing

---

### 10. Similar Meals Page (`similar_meals_page.dart`)
**Purpose**: Display meals similar to the current meal

**Features**:
- **Header**:
  - Title: "Similar to [Meal Name]"
  - Back button
  - Similarity score indicator (optional)
- **Content**:
  - Grid/list of similar meals
  - Each meal card shows:
    - Thumbnail image
    - Meal name
    - Similarity indicator (common ingredients count)
    - Category/Area tags
    - Common ingredients highlighted
  - Empty state: "No similar meals found"
- **Filter Options**:
  - Filter by similarity type (ingredients, category, area)
  - Sort by similarity score
- **Actions**:
  - View meal details
  - Add to favorites
  - Share meal

**State Management**:
- `SimilarMealsNotifier` - calculates and manages similar meals
- Loads on meal details page navigation

**Navigation**:
- Accessible from meal details page
- "View Similar Meals" button → full page

---

## Additional Features (Recommended)

### 1. Favorites System
- **Storage**: Local storage (SharedPreferences/Hive)
- **Features**:
  - Add/remove favorites from meal details
  - Favorites page (dedicated screen or filter)
  - Filter favorites in catalog page
  - Sync across app (indicator on meal cards)
  - Quick access from bottom navigation
- **State**: `FavoritesNotifier` with local persistence
- **Favorites Page**:
  - Dedicated page showing all favorited meals
  - Grid/list view toggle
  - Search within favorites
  - Sort by date added, name, category
  - Empty state with call-to-action
  - Quick remove from favorites

### 2. Search Functionality
- **Global Search**: Search bar in app bar
- **Features**:
  - Real-time search suggestions
  - Search history
  - Search by meal name, ingredient, category
- **State**: `SearchNotifier` with debouncing

### 3. Offline Support
- **Cache Strategy**:
  - Cache meal details locally
  - Cache images
  - Show cached data when offline
- **Storage**: Hive or SQLite for structured data

### 4. Image Loading & Caching
- **Package**: `cached_network_image`
- **Features**:
  - Placeholder while loading
  - Error image fallback
  - Memory and disk caching

### 5. Error Handling
- **Error States**:
  - Network errors
  - API errors
  - Empty states
- **User Feedback**: Snackbars, error dialogs, retry buttons

### 6. Loading States
- **Shimmers**: Loading placeholders for lists
- **Progress Indicators**: For data fetching
- **Skeleton Screens**: For better UX

### 7. Share Functionality
- Share meal recipe via system share
- Share meal link/image

### 8. Deep Linking
- Support deep links to meals, categories
- Shareable meal URLs

### 9. Dietary Filters
- **Purpose**: Filter meals based on dietary restrictions and preferences
- **Implementation**:
  - Manual tagging system (since MealDB API doesn't provide dietary info)
  - Analyze ingredients to auto-detect dietary compatibility
  - User-selectable dietary preferences stored locally
- **Filter Options**:
  - **Vegetarian**: No meat, fish, or poultry
  - **Vegan**: No animal products
  - **Gluten-Free**: No wheat, barley, rye
  - **Dairy-Free**: No milk, cheese, butter
  - **Keto**: Low-carb, high-fat compatible
  - **Paleo**: No processed foods, grains, legumes
  - **Low-Carb**: Minimal carbohydrates
  - **Halal**: Muslim dietary laws
  - **Kosher**: Jewish dietary laws
- **Features**:
  - Multi-select dietary filters
  - Filter chips in catalog page
  - Save dietary preferences in user settings
  - Visual indicators on meal cards (dietary badges)
  - Filter by ingredient exclusion (smart filtering)
- **State Management**:
  - `DietaryFiltersNotifier` - manages active dietary filters
  - `UserPreferencesNotifier` - saves user dietary preferences
- **Logic**:
  - Ingredient-based detection (check ingredient list)
  - Manual override option for users
  - Cache dietary tags locally to avoid recalculation

### 10. Recently Viewed Meals
- **Purpose**: Quick access to recently viewed recipes
- **Storage**: Local storage (Hive/SharedPreferences) - store last 20-50 meals
- **Features**:
  - Track meal views with timestamp
  - Display recently viewed meals on home page (optional section)
  - Dedicated "Recently Viewed" page/section
  - Remove from history option
  - Clear all history option
  - Sorted by most recent first
- **Display**:
  - Horizontal scrollable list on home page
  - Full page with search and filter
  - Grid/list view toggle
  - Quick access from navigation drawer
- **State Management**:
  - `RecentlyViewedNotifier` - manages recently viewed meals list
  - Auto-update on meal details page visit
- **Implementation**:
  - Store meal IDs with timestamps
  - Limit to last 50 meals (configurable)
  - Auto-remove old entries beyond limit
  - Persist across app sessions

### 11. Similar Meals
- **Purpose**: Discover related meals based on current meal
- **Features**:
  - Show similar meals on meal details page
  - "You might also like" section
  - Similarity based on:
    - Same category
    - Similar ingredients (ingredient overlap)
    - Same area/cuisine
    - Similar name/keywords
- **Display**:
  - Horizontal scrollable cards at bottom of meal details page
  - "View Similar Meals" button → full page
  - Similar meals page with filter options
- **Algorithm**:
  - Calculate ingredient overlap percentage
  - Prioritize same category/area
  - Weight by common ingredients
  - Show top 6-12 similar meals
- **State Management**:
  - `SimilarMealsNotifier` - calculates and manages similar meals
  - Cache similar meals for performance
- **API Strategy**:
  - Fetch meals by same category using `filter.php?c={category}`
  - Fetch meals by same area using `filter.php?a={area}`
  - Filter locally by ingredient overlap (compare ingredient lists)
  - Combine and rank results by similarity score
  - **Note**: Limited to 100 results per API call - may need multiple calls for large categories

## Technical Implementation

### Dependencies to Add
```yaml
dependencies:
  # HTTP Client
  http: ^1.1.0
  dio: ^5.4.0  # Alternative with better features
  
  # Image Loading
  cached_network_image: ^3.3.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # State Management (already have)
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.2
  
  # Utilities
  intl: ^0.18.1  # Date formatting
  url_launcher: ^6.2.2  # External links
  share_plus: ^7.2.1  # Share functionality
  
  # JSON Serialization
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  freezed: ^2.4.6  # For immutable models
```

### Data Models

#### Meal Entity
```dart
class Meal {
  final String id;
  final String name;
  final String? image;
  final String? category;
  final String? area;
  final String? instructions;
  final List<Ingredient> ingredients;
  final String? youtubeUrl;
  final String? sourceUrl;
  final String? thumbnailUrl;
}
```

#### Ingredient Entity
```dart
class Ingredient {
  final String name;
  final String? measurement;
  final String? image;
  final String? description;
}
```

#### Category Entity
```dart
class Category {
  final String name;
  final String? image;
  final String? description;
}
```

### State Management Structure

#### Notifiers
- `HomeNotifier` - Home page state
- `MealCatalogNotifier` - Catalog/filtering state
- `MealDetailsNotifier` - Meal details state
- `IngredientsSelectionNotifier` - Ingredient selection state
- `MatchingMealsNotifier` - Matching meals calculation
- `IngredientDetailsNotifier` - Ingredient details state
- `FavoritesNotifier` - Favorites management
- `SearchNotifier` - Search functionality
- `RecentlyViewedNotifier` - Recently viewed meals tracking
- `SimilarMealsNotifier` - Similar meals calculation
- `DietaryFiltersNotifier` - Dietary filters management
- `UserPreferencesNotifier` - User preferences (dietary, etc.)

### Navigation Structure
```
HomePage
  ├── MealDetailsPage
  │     └── SimilarMealsPage
  │           └── MealDetailsPage
  ├── IngredientsSelectionPage
  │     ├── IngredientDetailsPage
  │     └── MatchingMealsPage
  │           └── MealDetailsPage
  ├── MealCatalogPage
  │     └── MealDetailsPage
  │           └── SimilarMealsPage
  ├── FavoritesPage
  │     └── MealDetailsPage
  └── RecentlyViewedPage
        └── MealDetailsPage
```

## Parallel Development Plan (2 Developers)

### Phase 0: Shared Foundation (Week 1 - Day 1-2)
**Done together or assigned to one developer first**

**Shared Tasks (No Conflicts):**
- [ ] Set up MealDB API client (`lib/core/network/mealdb_api_client.dart`)
- [ ] Create base data models (`lib/features/meals/data/models/`):
  - [ ] `meal_model.dart`
  - [ ] `ingredient_model.dart`
  - [ ] `category_model.dart`
- [ ] Create domain entities (`lib/features/meals/domain/entities/`):
  - [ ] `meal.dart`
  - [ ] `ingredient.dart`
  - [ ] `category.dart`
- [ ] Create repository interfaces (`lib/features/meals/domain/repositories/`):
  - [ ] `meals_repository.dart`
- [ ] Set up error handling (`lib/core/error/`)
- [ ] Create app constants (`lib/core/constants/app_constants.dart`) - update with MealDB base URL
- [ ] Add dependencies to `pubspec.yaml` (http, cached_network_image, etc.)

**After Phase 0:** Both developers can work in parallel

---

### Developer 1: Core Discovery Features (Weeks 1-3)

#### Phase 1.1: API & Data Layer (Week 1 - Day 3-5)
**Files to create/modify:**
- `lib/features/meals/data/datasources/mealdb_remote_datasource.dart`
- `lib/features/meals/data/repositories_impl/meals_repository_impl.dart`
- `lib/features/meals/domain/usecases/get_meal_of_day.dart`
- `lib/features/meals/domain/usecases/get_categories.dart`
- `lib/features/meals/domain/usecases/get_meals_by_category.dart`
- `lib/features/meals/domain/usecases/get_meals_by_area.dart`

**Tasks:**
- [ ] Implement MealDB remote datasource with all API endpoints
- [ ] Implement meals repository
- [ ] Create use cases for categories, areas, meal of day
- [ ] Test API integration
- [ ] Handle API errors

#### Phase 1.2: Home Page (Week 2 - Day 1-3)
**Files to create:**
- `lib/features/meals/presentation/notifier/home_notifier.dart`
- `lib/features/meals/presentation/notifier/meal_of_day_notifier.dart`
- `lib/features/meals/presentation/pages/home_page.dart`
- `lib/features/meals/presentation/widgets/meal_of_day_card.dart`
- `lib/features/meals/presentation/widgets/category_card.dart`
- `lib/features/meals/presentation/widgets/category_list.dart`

**Tasks:**
- [ ] Implement Home page based on Figma design
- [ ] Create meal of day section
- [ ] Create categories section (horizontal scroll)
- [ ] Add navigation to meal details and catalog
- [ ] Implement bottom navigation bar
- [ ] Style according to Figma (green theme)

#### Phase 1.3: Meal Catalog & Search (Week 2 - Day 4-5, Week 3 - Day 1-2)
**Files to create:**
- `lib/features/meals/presentation/notifier/meal_catalog_notifier.dart`
- `lib/features/meals/presentation/notifier/search_notifier.dart`
- `lib/features/meals/presentation/pages/meal_catalog_page.dart`
- `lib/features/meals/presentation/widgets/meal_card.dart`
- `lib/features/meals/presentation/widgets/search_bar.dart`
- `lib/features/meals/presentation/widgets/filter_chips.dart`
- `lib/features/meals/domain/usecases/search_meals.dart`
- `lib/features/meals/domain/usecases/get_all_meals.dart`

**Tasks:**
- [ ] Implement Meal Catalog page
- [ ] Add search functionality (real-time with debouncing)
- [ ] Implement filtering by category
- [ ] Implement filtering by area
- [ ] Add sort options
- [ ] Create meal cards with grid/list view toggle
- [ ] Add loading states and skeletons

#### Phase 1.4: Meal Details Page (Week 3 - Day 3-5)
**Files to create:**
- `lib/features/meals/presentation/notifier/meal_details_notifier.dart`
- `lib/features/meals/presentation/pages/meal_details_page.dart`
- `lib/features/meals/presentation/widgets/meal_ingredients_list.dart`
- `lib/features/meals/presentation/widgets/meal_instructions.dart`
- `lib/features/meals/domain/usecases/get_meal_details.dart`

**Tasks:**
- [ ] Implement Meal Details page
- [ ] Display meal image, name, category, area
- [ ] Show ingredients list with measurements
- [ ] Display step-by-step instructions
- [ ] Add YouTube video link (if available)
- [ ] Add source link (if available)
- [ ] Implement favorite button (UI only - storage will be done by Dev 2)
- [ ] Add share functionality

---

### Developer 2: Ingredients & Enhanced Features (Weeks 1-3)

#### Phase 2.1: Ingredients Data & Logic (Week 1 - Day 3-5)
**Files to create:**
- `lib/features/meals/domain/usecases/get_all_ingredients.dart`
- `lib/features/meals/domain/usecases/get_meals_by_ingredient.dart`
- `lib/features/meals/domain/usecases/get_ingredient_details.dart`
- `lib/features/meals/domain/usecases/find_matching_meals.dart`
- `lib/features/meals/data/models/ingredient_model.dart` (extend if needed)

**Tasks:**
- [ ] Implement ingredient-related use cases
- [ ] Create matching meals algorithm (ingredient intersection logic)
- [ ] Test ingredient filtering logic
- [ ] Create ingredient matching utility functions

#### Phase 2.2: Ingredients Selection Page (Week 2 - Day 1-3)
**Files to create:**
- `lib/features/meals/presentation/notifier/ingredients_selection_notifier.dart`
- `lib/features/meals/presentation/notifier/matching_meals_notifier.dart`
- `lib/features/meals/presentation/pages/ingredients_selection_page.dart`
- `lib/features/meals/presentation/widgets/ingredient_card.dart`
- `lib/features/meals/presentation/widgets/selection_indicator.dart`
- `lib/features/meals/presentation/widgets/selection_summary_bar.dart`

**Tasks:**
- [ ] Implement Ingredients Selection page
- [ ] Create ingredient cards with images
- [ ] Add multi-select functionality
- [ ] Implement selection indicator (visual feedback)
- [ ] Create bottom action bar with selection count
- [ ] Show matching meals count
- [ ] Add long-press gesture for ingredient details
- [ ] Implement search within ingredients

#### Phase 2.3: Matching Meals & Ingredient Details (Week 2 - Day 4-5, Week 3 - Day 1-2)
**Files to create:**
- `lib/features/meals/presentation/pages/matching_meals_page.dart`
- `lib/features/meals/presentation/pages/ingredient_details_page.dart`
- `lib/features/meals/presentation/notifier/ingredient_details_notifier.dart`
- `lib/features/meals/presentation/widgets/matching_meal_card.dart`

**Tasks:**
- [ ] Implement Matching Meals page
- [ ] Display meals that match selected ingredients
- [ ] Show ingredient availability indicator
- [ ] Implement Ingredient Details page
- [ ] Display ingredient information
- [ ] Show meals using this ingredient
- [ ] Add navigation between pages

#### Phase 2.4: Favorites & Local Storage (Week 3 - Day 3-5)
**Files to create:**
- `lib/features/meals/data/datasources/favorites_local_datasource.dart`
- `lib/features/meals/presentation/notifier/favorites_notifier.dart`
- `lib/features/meals/presentation/pages/favorites_page.dart`
- `lib/features/meals/presentation/widgets/favorites_filter.dart`
- `lib/shared/storage/local_storage_service.dart` (or use Hive/SharedPreferences directly)

**Tasks:**
- [ ] Set up local storage (Hive or SharedPreferences)
- [ ] Implement favorites local datasource
- [ ] Create FavoritesNotifier with persistence
- [ ] Implement Favorites page
- [ ] Add search within favorites
- [ ] Add filter/sort options
- [ ] Integrate favorites button in meal details (from Dev 1)
- [ ] Add favorites indicator on meal cards

---

### Phase 3: Parallel Enhancement (Week 4)

#### Developer 1: Additional Discovery Features
**Files to create:**
- `lib/features/meals/presentation/notifier/similar_meals_notifier.dart`
- `lib/features/meals/presentation/pages/similar_meals_page.dart`
- `lib/features/meals/presentation/widgets/similar_meal_card.dart`
- `lib/features/meals/domain/usecases/get_similar_meals.dart`

**Tasks:**
- [ ] Implement similar meals algorithm
- [ ] Create Similar Meals page
- [ ] Add "You might also like" section to Meal Details
- [ ] Integrate with Meal Details page (from Phase 1.4)

#### Developer 2: User Experience Features
**Files to create:**
- `lib/features/meals/presentation/notifier/recently_viewed_notifier.dart`
- `lib/features/meals/presentation/pages/recently_viewed_page.dart`
- `lib/features/meals/presentation/notifier/dietary_filters_notifier.dart`
- `lib/features/meals/presentation/notifier/user_preferences_notifier.dart`
- `lib/features/meals/presentation/widgets/dietary_filter_chips.dart`
- `lib/features/meals/domain/usecases/filter_meals_by_dietary.dart`

**Tasks:**
- [ ] Implement Recently Viewed tracking
- [ ] Create Recently Viewed page
- [ ] Add recently viewed section to Home page
- [ ] Implement dietary filters logic
- [ ] Create dietary filter chips
- [ ] Integrate dietary filters into Meal Catalog page
- [ ] Save user dietary preferences

---

### Phase 4: Integration & Polish (Week 5)

#### Both Developers Together:
**Integration Tasks:**
- [ ] Merge all features and test navigation flows
- [ ] Integrate similar meals into meal details
- [ ] Integrate dietary filters into catalog
- [ ] Add recently viewed to home page
- [ ] Test all cross-feature interactions

#### Developer 1:
- [ ] Add image caching optimization
- [ ] Improve loading states and skeletons
- [ ] Polish Home page and Catalog UI
- [ ] Add error handling improvements

#### Developer 2:
- [ ] Optimize local storage operations
- [ ] Improve matching meals algorithm performance
- [ ] Polish Ingredients pages UI
- [ ] Add dietary filter badges to meal cards

---

### Phase 5: Testing & Finalization (Week 6)

#### Developer 1: Testing Focus
- [ ] Write unit tests for API datasource
- [ ] Write unit tests for repository
- [ ] Write widget tests for Home page
- [ ] Write widget tests for Meal Catalog
- [ ] Write widget tests for Meal Details
- [ ] Performance testing for search/filter

#### Developer 2: Testing Focus
- [ ] Write unit tests for matching meals algorithm
- [ ] Write unit tests for local storage
- [ ] Write widget tests for Ingredients Selection
- [ ] Write widget tests for Favorites page
- [ ] Write widget tests for Recently Viewed
- [ ] Test dietary filter logic

#### Both Together:
- [ ] Integration testing
- [ ] End-to-end user flow testing
- [ ] Bug fixes
- [ ] Final UI/UX polish
- [ ] Documentation updates

---

## Task Separation Strategy

### File Ownership to Minimize Conflicts:

**Developer 1 Works On:**
- `lib/features/meals/presentation/pages/home_page.dart`
- `lib/features/meals/presentation/pages/meal_catalog_page.dart`
- `lib/features/meals/presentation/pages/meal_details_page.dart`
- `lib/features/meals/presentation/pages/similar_meals_page.dart`
- `lib/features/meals/presentation/notifier/home_notifier.dart`
- `lib/features/meals/presentation/notifier/meal_catalog_notifier.dart`
- `lib/features/meals/presentation/notifier/meal_details_notifier.dart`
- `lib/features/meals/presentation/notifier/search_notifier.dart`
- `lib/features/meals/presentation/notifier/similar_meals_notifier.dart`
- `lib/features/meals/data/datasources/mealdb_remote_datasource.dart`
- `lib/features/meals/presentation/widgets/meal_card.dart`
- `lib/features/meals/presentation/widgets/category_card.dart`

**Developer 2 Works On:**
- `lib/features/meals/presentation/pages/ingredients_selection_page.dart`
- `lib/features/meals/presentation/pages/matching_meals_page.dart`
- `lib/features/meals/presentation/pages/ingredient_details_page.dart`
- `lib/features/meals/presentation/pages/favorites_page.dart`
- `lib/features/meals/presentation/pages/recently_viewed_page.dart`
- `lib/features/meals/presentation/notifier/ingredients_selection_notifier.dart`
- `lib/features/meals/presentation/notifier/matching_meals_notifier.dart`
- `lib/features/meals/presentation/notifier/ingredient_details_notifier.dart`
- `lib/features/meals/presentation/notifier/favorites_notifier.dart`
- `lib/features/meals/presentation/notifier/recently_viewed_notifier.dart`
- `lib/features/meals/presentation/notifier/dietary_filters_notifier.dart`
- `lib/features/meals/data/datasources/favorites_local_datasource.dart`
- `lib/features/meals/presentation/widgets/ingredient_card.dart`

**Shared Files (Coordination Needed):**
- `lib/features/meals/data/models/*.dart` - Both use, but created in Phase 0
- `lib/features/meals/domain/entities/*.dart` - Both use, but created in Phase 0
- `lib/features/meals/domain/repositories/meals_repository.dart` - Both use
- `lib/features/meals/data/repositories_impl/meals_repository_impl.dart` - Dev 1 implements, Dev 2 uses
- `lib/app.dart` - Navigation setup (coordinate)
- `lib/core/constants/app_constants.dart` - Both use
- `lib/core/network/api_client.dart` - Shared base

### Communication Points:

1. **End of Phase 0:** Share data models and API client
2. **End of Week 1:** Dev 1 shares repository implementation
3. **End of Week 2:** Coordinate navigation routes
4. **End of Week 3:** Integration meeting for favorites button
5. **Daily:** Quick sync on shared dependencies
6. **Before merging:** Always pull latest changes

### Git Workflow:

1. **Branch Strategy:**
   - `main` - Production-ready code
   - `dev1/feature-name` - Developer 1 feature branches
   - `dev2/feature-name` - Developer 2 feature branches
   - `integration` - Integration testing branch

2. **Merge Process:**
   - Create feature branch from `main`
   - Work on feature independently
   - Before merging: Pull latest `main`, rebase if needed
   - Create PR to `main` or `integration`
   - Review and merge

3. **Conflict Resolution:**
   - Shared files: Coordinate changes
   - Models: One dev adds, other updates
   - Navigation: Use feature flags or coordinate route additions

## API Usage Strategy

### API Key Configuration
- **Development**: Use test key `1` in `.env` file:
  ```
  MEALDB_API_KEY=1
  MEALDB_BASE_URL=https://www.themealdb.com/api/json/v1/
  ```
- **Production**: Replace with supporter API key before app store release
- **Base URL Format**: `{MEALDB_BASE_URL}{MEALDB_API_KEY}/`

### Rate Limiting Considerations
- MealDB API is free but may have rate limits
- **100 Item Limit**: Free API returns max 100 items per query
- Implement caching for frequently accessed data
- Batch API calls where possible (but respect rate limits)
- Cache category/area lists (rarely change)
- Cache meal details (fetch once, reuse)

### Caching Strategy
1. **Categories/Areas**: Cache for 24 hours (data rarely changes)
2. **Meal Details**: Cache indefinitely (data rarely changes)
3. **Images**: Cache indefinitely using `cached_network_image`
4. **Search Results**: Cache for 1 hour
5. **Ingredient Lists**: Cache for 24 hours

### Handling 100 Item Limit
- **Problem**: Free API returns max 100 items per query
- **Solutions**:
  1. **Pagination**: For large lists (categories, areas), implement pagination
  2. **Multiple Queries**: For categories with >100 meals, make multiple queries
  3. **Client-Side Filtering**: Fetch all available data and filter client-side
  4. **Progressive Loading**: Load more items as user scrolls
  5. **Cache Aggregation**: Combine results from multiple API calls

### Ingredient Name Formatting
- **Important**: API requires underscores for spaces in ingredient names
- **Format**: `chicken breast` → `chicken_breast` in API calls
- **Image URLs**: Also use underscores: `chicken_breast.png`
- **Implementation**: Create utility function to format ingredient names:
  ```dart
  String formatIngredientName(String name) {
    return name.toLowerCase().replaceAll(' ', '_');
  }
  ```

### Multi-Ingredient Filter Workaround (Free API)
Since free API doesn't support multi-ingredient filter:
1. Make separate API calls for each selected ingredient
2. Combine results in memory
3. Find intersection (meals containing ALL ingredients)
4. Cache results to avoid repeated calls
5. **Performance**: Limit to reasonable number of selected ingredients (e.g., max 5-10)

### Image URL Handling
- **Meal Images**: Use image URL from API response, add size suffix:
  - Original: `{imageUrl}`
  - Small: `{imageUrl}/preview` or `{imageUrl}/small`
  - Medium: `{imageUrl}/medium`
  - Large: `{imageUrl}/large`
- **Ingredient Images**: Construct URL manually:
  - Base: `https://www.themealdb.com/images/ingredients/`
  - Format: `{base}{ingredient_name}.png`
  - Sizes: `{ingredient_name}-small.png`, `-medium.png`, `-large.png`
  - Replace spaces with underscores

### Optimization Tips
- Pre-fetch meal of the day on app start
- Pre-load popular categories (cache after first load)
- Lazy load images (use `cached_network_image` with placeholders)
- Debounce search queries (wait 300-500ms after user stops typing)
- Use pagination for large lists (load 20-50 items at a time)
- Cache ingredient-to-meal mappings locally
- Batch ingredient filter requests (but respect rate limits)
- Show loading states during API calls
- Handle network errors gracefully with retry logic

### Error Handling
- **Network Errors**: Show retry button, cache fallback if available
- **API Errors**: Handle empty responses gracefully
- **Rate Limiting**: Show user-friendly message if rate limited
- **Invalid Responses**: Validate API response structure before parsing
- **Image Loading Failures**: Use placeholder images

### Premium API Considerations (Future)
If upgrading to supporter status:
- Multi-ingredient filter: Use `filter.php?i=ing1,ing2,ing3`
- Random selection: Use `randomselection.php` for 10 random meals
- Latest meals: Use `latest.php` for newest additions
- Full database: Access complete database without 100 item limit

## Testing Strategy

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

## UI/UX Guidelines

### Design System
- **Colors**: Based on Figma (green primary, clean white background)
- **Typography**: Material Design 3 typography scale
- **Spacing**: Consistent 8px grid system
- **Components**: Reusable cards, buttons, inputs

### Responsive Design
- Support different screen sizes
- Tablet layout considerations
- Landscape orientation support

### Accessibility
- Semantic labels
- Screen reader support
- High contrast mode support
- Touch target sizes (minimum 48x48)

## Future Enhancements (Post-MVP)

1. **Meal Planning**: Weekly meal planning feature
2. **Shopping Lists**: Generate shopping lists from selected meals
3. **Nutrition Info**: Calculate nutrition from ingredients
4. **Cooking Timer**: Built-in timer for recipes
5. **User Accounts**: Save preferences, sync favorites
6. **Social Features**: Share meals, rate recipes
7. **Offline Mode**: Full offline functionality
8. **Dark Mode**: Theme support
9. **Multi-language**: Internationalization

## Implementation Notes

### API Key Management
- Store API key in `.env` file (already configured for flutter_dotenv)
- Use test key `1` for development
- Replace with supporter key before production release
- Never commit production API key to version control

### Ingredient Image Handling
- MealDB API provides ingredient images but requires manual URL construction
- Format: `https://www.themealdb.com/images/ingredients/{ingredient_name}.png`
- Replace spaces with underscores (e.g., `chicken breast` → `chicken_breast.png`)
- Available sizes: default, `-small`, `-medium`, `-large`
- Handle missing images gracefully with placeholder

### Data Limitations
- **100 Item Limit**: Free API returns max 100 items per query
- **Multi-Ingredient**: Not available in free tier - implement client-side intersection
- **Incomplete Data**: Some meals may have missing fields (images, instructions, etc.) - handle gracefully
- **Image Loading**: Some images may be slow or missing - use placeholders and caching

### Offline Support
- Cache meal details locally (Hive or SQLite)
- Cache images using `cached_network_image`
- Cache category/area lists (rarely change)
- Show cached data when offline
- Implement sync mechanism when back online

### Performance Considerations
- API calls are free but may be slow - implement proper loading states
- Image loading can be slow - use thumbnails and lazy loading
- Large lists (100+ items) - implement pagination or virtual scrolling
- Multiple ingredient selection - limit to reasonable number (5-10) to avoid too many API calls
- Cache frequently accessed data to minimize API calls

### Production Checklist
- [ ] Replace test API key with supporter key
- [ ] Test all API endpoints with production key
- [ ] Verify image URLs are loading correctly
- [ ] Test multi-ingredient workaround performance
- [ ] Implement proper error handling for API failures
- [ ] Set up image caching for better performance
- [ ] Test offline functionality with cached data
- [ ] Verify 100 item limit handling for all features

