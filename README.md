<div align="center">

# 🍲 Recipe App - Showcase Mobile Application

![Swift](https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=ios&logoColor=white)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-blue?style=for-the-badge)
![Coordinator](https://img.shields.io/badge/Navigation-Coordinator-orange?style=for-the-badge)

*A showcase mobile application built to demonstrate iOS development practices using Swift, UIKit, and MVVM Architecture.*

</div>

## 📖 About the Project

The **Recipe App** focuses on implementing real-world mobile application features such as authentication, API integration, advanced searching & filtering, data handling, and robust UI state management.

This project showcase clean architecture, scalable code organization, and best-in-class iOS development practices.

---

## ✨ Key Features

- **Authentication**: Login/signup against DummyJSON, with session tokens in the Keychain.
- **Discover & Search**: Browse recipes with cuisine filter chips and pagination on Home; a
  separate Search screen adds diet filters and recent-search history.
- **Recipe Detail**: Full recipe view — ingredients with a servings stepper, instruction steps,
  share sheet.
- **Saved Recipes**: Save/remove favorite recipes, per logged-in user, persisted locally
  (Core Data-backed) with undo-on-remove on the Saved tab.
- **Notifications**: Local notifications on save/remove, plus an in-app history log with
  All/Saved/Removed filter tabs, backed by Core Data.
- **Offline Support & Dummy Data Fallback**: If the Spoonacular API is unreachable or its quota is
  exhausted, the app transparently falls back to bundled dummy recipe data so the UI never goes
  empty.
- **Profile**: User details header, segmented Recipes/Videos/Tags tabs, logout with confirmation.
- **Custom Bottom Navigation**: A hand-built bottom bar with a centre FAB, replacing
  `UITabBarController` so tab screens keep full control of their own navigation stack.
- **Runtime Permissions**: A single extensible permission layer (currently notifications),
  requested once on first Home appearance.
- **Add Recipe (Coming Soon)**: The FAB on the dashboard is a placeholder — the real add-recipe
  flow hasn't been designed yet.

---

## 🛠 Tech Stack & Libraries

| Category               | Library                                                                | Version |
|-------------------------|-------------------------------------------------------------------------|---------|
| Language                | [Swift](https://www.swift.org/)                                         | 5.0     |
| UI                      | UIKit — Storyboards for screen scaffolding, code for reusable components | —       |
| Architecture            | MVVM + Repository, Coordinator-based navigation                         | —       |
| Reactive                | Combine (`@Published`, `AnyPublisher`)                                  | —       |
| Concurrency             | Swift Concurrency (`async`/`await`, `Task`), `@MainActor` view models   | —       |
| Networking              | [Alamofire](https://github.com/Alamofire/Alamofire)                     | 5.12+   |
| Local persistence       | Core Data (`RecipeApp.xcdatamodeld`) — saved recipes, notification log  | —       |
| Secure storage          | Keychain (`KeychainSessionStore`) for session tokens                    | —       |
| Non-sensitive prefs     | `UserDefaults` — recent searches                                        | —       |
| Notifications           | `UserNotifications` — local only, no push or APNs                       | —       |
| Toasts / snackbars      | [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages)       | 10.0.2+ |
| Dependency management   | Swift Package Manager                                                   | —       |
| Deployment target       | iOS 26.0                                                                 | Built with Xcode 26 / iOS 26.5 SDK |

---

## 🏗 Architecture

```
View (Storyboard/UIKit) → ViewModel (Combine) → Repository → Store (Keychain / UserDefaults / Core Data / API)
                ↑
          Coordinator (navigation only, no business logic)
```

- **Coordinators** (`Core/Navigation/`) own navigation and child-coordinator lifecycle; view
  controllers never push/present each other directly.
- **ViewModels** are `@MainActor`, publish `ViewState<T>` (idle/loading/success/failure), and hold
  no UIKit references.
- **Repositories** (`RecipeData/DataSource/Repository/`) abstract network vs. bundled dummy data
  behind `FallbackRecipeRepository`, and are the only layer that talks to storage.
- **`DependencyContainer`** (`App/DependencyContainer.swift`) is the composition root — the Koin
  module equivalent — rebuilt on every login/logout so no store can leak the previous user's data.

---

## 🌐 Data Sources

| API | Used for |
|---|---|
| [Spoonacular](https://spoonacular.com/food-api) | Recipe search, detail, cuisine/diet filters |
| [DummyJSON](https://dummyjson.com/) | Auth (login/signup), user details |
| Bundled JSON (`DummyRecipeData.json`, `DummyRecipeDetail.json`) | Offline / quota-exceeded fallback |

---

## 📂 Project Structure

```
RecipeApp/RecipeApp/
├── App/            # AppDelegate, SceneDelegate, AppCoordinator, DependencyContainer
├── Core/           # Cross-cutting infrastructure
│   ├── Configuration/   # AppSecrets — bundled Secrets.plist reader
│   ├── Navigation/      # Coordinator protocols, DashboardNavigationController
│   ├── Networking/      # APIClient, NetworkError, endpoint definitions
│   ├── Notifications/   # Local notification scheduling and deep links
│   ├── Permissions/     # Extensible runtime-permission layer
│   ├── Persistence/     # CoreDataStack and managed-object subclasses
│   ├── StorageManagers/ # Keychain, UserDefaults, and Core Data stores
│   └── Extensions/      # Foundation and UIKit helpers
├── Common/         # Shared UI: ViewState, EmptyStateView, ScrollVisibilityTracker, view extensions
├── Modules/        # One folder per screen — each with its own Coordinator, ViewModel(s),
│                   # ViewController(s), and protocols:
│                   # Auth, OnBoarding, DashBoard, Home, Search, RecipeDetail,
│                   # SavedRecipe, Notification, Profile
└── RecipeData/     # DTOs, UI models, and repository implementations
```

Modules are self-contained: a screen's coordinator, view models, view controllers, and delegate
protocols live together, so a feature can be read or removed without tracing it across the tree.

---

## 📌 Current Status

Actively in development. Recently landed:

- Custom bottom navigation with centre FAB, replacing `UITabBarController`
- Full notification feature (permission, local notifications, in-app log screen)
- Saved recipes migrated from UserDefaults to Core Data, closing the last storage-parity gap
  with Android
