# 📱 StaffPulse Frontend — Enterprise AI Leave & Workflow Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-BLoC%20%2B%20Clean%20Design-blueviolet)](#-architecture--state-management)
[![UI Design](https://img.shields.io/badge/Design-Apple%20Liquid%20Glass-22272e)](#-ui--ux-design-language)
[![Tests](https://img.shields.io/badge/Tests-40%20Passed-success)](test/)

**StaffPulse Frontend** is a next-generation cross-platform mobile, desktop, and web application for intelligent personnel management and automated leave orchestration. It pairs an Apple VisionOS / macOS dark **Liquid Glass** aesthetic with live AI reasoning streams (**Process-First RAG** via Ollama) and interactive **Flowable BPMN 2.0** process diagrams.

---

## 📑 Table of Contents

- [✨ Key Features](#-key-features)
- [🏗️ Architecture & State Management](#️-architecture--state-management)
- [🎨 UI & UX Design Language](#-ui--ux-design-language)
- [📁 Project Structure](#-project-structure)
- [⚡ Quick Start & Commands](#-quick-start--commands)
- [⚙️ Environment Configuration](#️-environment-configuration)
- [🛡️ Non-Negotiable Frontend Rules](#️-non-negotiable-frontend-rules)
- [🧪 Testing & Quality Assurance](#-testing--quality-assurance)

---

## ✨ Key Features

- **Conversational RAG Leave Submission:** Natural language leave application in Persian (e.g. *"فردا به علت دندان‌درد شدید نیاز به ۱ روز استعلاجی دارم"*).
- **Live AI Thinking Modal (`RagThinkingSheet`):** Real-time Server-Sent Events (SSE) streaming illustrating policy lookups, risk scores, and Fast-Track auto-approval decisions.
- **Interactive BPMN 2.0 Diagram Viewer (`ProcessDiagramSheet`):** Live diagram streaming from Flowable engine displaying active execution tokens highlighted in red, with automatic fallback for completed/historical requests.
- **Manager Approval Cartable (`ManagerTasksScreen`):** Real-time queue for Unit Managers, HR Medical Audits, and Senior Executives with built-in Anti-Self-Approval guard and Persian search filtering.
- **Leave History & Balance Cards (`LeaveHistoryScreen`):** Visual annual and sick leave quota trackers, status badges, and complete audit trail timelines.
- **Multi-Role RBAC:** Automatic UI tailoring according to user role (`EMPLOYEE`, `MANAGER`, `HR`, `EXECUTIVE`, `ADMIN`).

---

## 🏗️ Architecture & State Management

StaffPulse Frontend strictly follows **Clean Architecture** and the **BLoC (Business Logic Component)** pattern:

```text
Presentation Layer (Screens & Widgets)
          ▲
          │ Events & States
          ▼
Controller Layer (BLoC / Cubit)
          ▲
          │ Calls
          ▼
Repository Layer (Data Abstraction & Mappers)
          ▲
          │ Requests (DataState<T>)
          ▼
Core Services (ApiClient [Dio], StorageService [SharedPreferences], Locator [GetIt])
```

- **Dependency Injection:** Powered by [`get_it`](https://pub.dev/packages/get_it). All dependencies, repositories, and BLoC factories are registered in [`lib/core/services/locator.dart`](lib/core/services/locator.dart).
- **Navigation:** Declarative routing configured via [`go_router`](https://pub.dev/packages/go_router) in [`lib/core/services/router.dart`](lib/core/services/router.dart).
- **Unified Network State:** All asynchronous repository calls return `DataState<T>` (`DataSuccess<T>` or `DataFailed<T>`), eliminating unhandled network crashes.
- **Global Controller:** [`GlobalController`](lib/core/services/global_controller.dart) manages session token, active user profile, and authentication broadcast.

---

## 🎨 UI & UX Design Language

- **Dark Liquid Glassmorphism:** Powered by `liquid_glass_easy` for authentic Apple VisionOS refraction, dynamic specular edge highlights, and subtle blur over deep dark backgrounds (`#0B0E14`).
- **ThinkingOrb Interactive Button (`CustomOrbButton`):** Custom high-end button integrating 9 AI thinking states (`working`, `searching`, `evaluating`, etc.) with spring tactile feedback and smooth transitions between idle, loading, success, and error states.
- **Persian RTL First:** Native right-to-left typography, custom Persian font metrics, and RTL directional wrappers across all views.
- **High-Contrast Status Indicators:** Standardized semantic colors for Fast-Track auto-approved, pending manager review, medical audit, rejected, and cancelled states.

---

## 📁 Project Structure

```text
StaffPulseFrontend/
├── assets/
│   └── .env                                  # Environment variables
├── lib/
│   ├── main.dart                             # Application entrypoint & Theme configuration
│   ├── core/                                 # Global foundation
│   │   ├── configs/                          # Colors, constants, and API endpoints
│   │   ├── model_serializer/                 # JSON model serializers (User, Leave, Task, Stream)
│   │   ├── services/                         # ApiClient, AppToast, Locator, Router, Theme
│   │   ├── utils/                            # DataState, BlocStates, StatusManagementWidget
│   │   └── widget/components/                # CustomOrbButton, glassmorphic containers
│   ├── login/                                # Authentication feature
│   │   ├── models/                           # User UI models & mappers
│   │   ├── presentation/                     # LoginScreen & LoginBloc
│   │   └── repository/                       # AuthRepository
│   ├── home/                                 # Dashboard & Home feature
│   │   └── presentation/screens/             # HomeScreen
│   ├── leave/                                # Core leave orchestration feature
│   │   ├── presentation/
│   │   │   ├── controller/                   # LeaveSubmitBloc, ManagerTasksBloc, LeaveHistoryBloc
│   │   │   ├── screens/                      # LeaveRequestScreen, ManagerTasksScreen, LeaveHistoryScreen
│   │   │   └── widgets/                      # RagThinkingSheet, ProcessDiagramSheet
│   │   └── repository/                       # LeaveRepository
│   ├── splash/                               # Splash & authentication gateway
│   │   ├── presentation/                     # SplashScreen & SplashBloc
│   │   └── repository/                       # SplashRepository
│   └── l10n/                                 # Localization files (.arb)
└── test/                                     # Unit, BLoC, and Widget tests (40 tests)
```

---

## ⚡ Quick Start & Commands

### Prerequisites
- **Flutter SDK:** $\ge$ 3.13.3
- **Dart SDK:** $\ge$ 3.1.0
- **Backend Service:** Running StaffPulse FastAPI Backend on `http://127.0.0.1:8000`

### Setup & Run

```bash
# 1. Clone repository and navigate to frontend
cd StaffPulseFrontend

# 2. Install dependencies
flutter pub get

# 3. Run all unit & BLoC tests
flutter test

# 4. Launch on Chrome (Web)
flutter run -d chrome

# 5. Launch on Windows Desktop
flutter run -d windows
```

---

## ⚙️ Environment Configuration

Configuration is managed via `.env` in the root folder:

```properties
# Backend API Base URL
API_BASE_URL=http://127.0.0.1:8000/api/v1
```

If `.env` is omitted, `AppConstants.apiBaseUrl` automatically defaults to:
- **Web / Desktop:** `http://127.0.0.1:8000/api/v1`
- **Android Emulator:** `http://10.0.2.2:8000/api/v1`

---

## 🛡️ Non-Negotiable Frontend Rules

Any engineer or AI agent working on this codebase **MUST** respect the following invariants:

1. **Anti-Self-Approval UI Guard:**
   - In `ManagerTasksScreen`, if `task.applicantEmployeeCode == currentUser.employeeCode`, approve/reject actions **MUST BE DISABLED** and tagged with a "Self-Request" badge.
2. **RTL Persian Wrapping:**
   - Persian screens, bottom sheets, and dialogs must always be wrapped in `Directionality(textDirection: TextDirection.rtl)`.
3. **Graceful Diagram Fallback:**
   - Completed leave requests in `ProcessDiagramSheet` must gracefully display the process diagram without error or crashing.
4. **No Direct Network Calls in UI:**
   - All network calls must pass through Repositories and BLoCs; never call `ApiClient` or `Dio` directly from a Widget `build()` method.
5. **Zero Test Regressions:**
   - Any modification must maintain 100% passing rate on the test suite (`flutter test`).

---

## 🧪 Testing & Quality Assurance

StaffPulse Frontend includes a comprehensive test suite covering BLoC states, mappers, services, and widgets:

```bash
flutter test
```

### Key Test Suites:
- `login_bloc_test.dart` & `login_mapper_test.dart`: Credential validation & token handling.
- `leave_submit_bloc_test.dart`: SSE streaming & AI auto-approval states.
- `manager_tasks_bloc_test.dart`: Anti-self-approval filtering & task actions.
- `leave_history_bloc_test.dart`: Quotas and audit log timeline parsing.
- `custom_orb_button_test.dart`: Orb animations, glass styling, and tactile states.
