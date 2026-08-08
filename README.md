<div align="center">

# 🍲 Recipe App - Showcase Mobile Application

![Swift](https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=ios&logoColor=white)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-blue?style=for-the-badge)
![Coordinator](https://img.shields.io/badge/Navigation-Coordinator-orange?style=for-the-badge)

*A showcase mobile application built to demonstrate iOS development practices using Swift, UIKit, and MVVM Architecture.*

</div>

## 📖 About the Project

The **Recipe App** focuses on implementing real-world mobile application features such as
authentication, API integration, searching, data handling, navigation, and UI state management.

This is the iOS counterpart of the project's [Android app](https://github.com/Bhumik91/recipe-demo-android),
built independently but kept behaviourally and architecturally equivalent to it
feature-for-feature.

This project is part of a Mobile Development learning program and is intended to showcase clean
architecture, scalable code organization, and best-in-class iOS development practices.

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

| Category | Library | Notes |
|---|---|---|
| Language | [Swift](https://www.swift.org/) | |
| UI | UIKit, Storyboards for screen scaffolding, code for reusable components | |
| Architecture | MVVM + Repository, Coordinator-based navigation | See [Architecture](#-architecture) |
| Reactive | Combine (`@Published`, `AnyPublisher`) | No RxSwift/third-party reactive dependency |
| Networking | [Alamofire](https://github.com/Alamofire/Alamofire) | |
| Local persistence | Core Data (`RecipeApp.xcdatamodeld`) — saved recipes, notification log | Room equivalent |
| Secure storage | Keychain (`KeychainSessionStore`) for session tokens | Keystore equivalent |
| Non-sensitive prefs | `UserDefaults` — recent searches | SharedPreferences equivalent |
| Notifications | `UserNotifications` (local only — no push, no APNs) | |
| Messaging / toasts | [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages) | |
| Async | Swift Concurrency (`async`/`await`, `Task`) | |
| Deployment target | iOS 18.1 | |

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
├── App/                 # AppDelegate, SceneDelegate, AppCoordinator, DependencyContainer
├── Core/                # Navigation, Networking, Persistence, Permissions, Notifications, Storage
├── Common/              # Shared UI components, extensions, view state
├── Modules/              # One folder per screen: Auth, Home, Search, RecipeDetail,
│                          SavedRecipe, Notification, Profile, DashBoard, OnBoarding, Add
└── RecipeData/           # DTOs, UI models, repositories
```

---

## 📌 Current Status

Actively in development. Recently landed:

- Custom bottom navigation with centre FAB, replacing `UITabBarController`
- Full notification feature (permission, local notifications, in-app log screen)
- Saved recipes migrated from UserDefaults to Core Data, closing the last storage-parity gap
  with Android
