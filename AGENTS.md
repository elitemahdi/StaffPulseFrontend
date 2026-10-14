# 🛑 MANDATORY DEVELOPER & AGENT GUIDE FOR STAFFPULSE FRONTEND

> **STOP & READ FIRST:** Any AI agent (Antigravity, Cursor, Copilot, Claude Code, etc.) or software engineer working on this repository **MUST** read and adhere to the guidelines, architectural invariants, and UX rules outlined in this document before generating or modifying code.

---

## 📌 1. Project Overview & Architecture

**StaffPulse Frontend** is an enterprise-grade cross-platform Flutter application providing an Apple VisionOS / macOS dark **Liquid Glass** interface for personnel management and AI-orchestrated leave workflows:
- **Framework:** Flutter 3.13+ with Dart 3.x
- **State Management:** BLoC pattern (`flutter_bloc`, `equatable`) with strictly segregated Event, State, and Bloc files
- **Service Locator / DI:** `get_it` configured in `lib/core/services/locator.dart`
- **Navigation:** Declarative routing using `go_router` in `lib/core/services/router.dart`
- **Network Client:** `dio` managed via `ApiClient` with automated Bearer token injection and `DataState<T>` wrappers
- **AI UI Elements:** Custom `ThinkingOrb` animated indicators in `CustomOrbButton` and real-time SSE streaming modals in `RagThinkingSheet`
- **Workflow Visualization:** Interactive zoomable BPMN 2.0 diagram viewer in `ProcessDiagramSheet` consuming Flowable diagram streams

---

## ⚡ 2. Environment & CLI Commands

Always run Flutter commands from the `StaffPulseFrontend` directory:

```bash
# Install dependencies
flutter pub get

# Run all test suites (ALL 40 tests MUST PASS)
flutter test

# Run code analysis
flutter analyze

# Run on Chrome
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows
```

---

## 🚨 3. Non-Negotiable Architectural Invariants & Rules

When modifying or adding features, you **MUST NEVER** violate the following rules:

### A. Anti-Self-Approval UI Guard (MANDATORY)
- In `ManagerTasksScreen`, if a pending task's applicant employee code matches the current authenticated user (`task.applicantEmployeeCode == currentUser.employeeCode`):
  1. The task card **MUST** display a distinct badge indicating *"درخواست خود کاربر"* (Self-Request).
  2. The Approve and Reject buttons **MUST BE DISABLED** or hidden.
  3. A user can **NEVER** be allowed to trigger an approval action on their own leave request from the UI.

### B. Persian RTL Directionality
- All user-facing screens, modals, dialogs, and bottom sheets **MUST** be explicitly wrapped with `Directionality(textDirection: TextDirection.rtl)`.
- Use Persian digits and formatting where appropriate and ensure alignment matches RTL standards.

### C. Clean Architecture & Separation of Concerns
- **Never call `ApiClient` or `Dio` directly from a Widget.**
- Flow must strictly be: `Widget` $\rightarrow$ `Bloc.add(Event)` $\rightarrow$ `Repository` $\rightarrow$ `ApiClient` $\rightarrow$ `DataState<T>` $\rightarrow$ `State emit` $\rightarrow$ `BlocBuilder`.
- All asynchronous repository methods must return `DataState<T>` (`DataSuccess<T>` or `DataFailed<T>`).

### D. Process Diagram Graceful Handling
- `ProcessDiagramSheet` must handle both:
  1. Active process instances (returns highlighted token PNG).
  2. Completed/historical process instances (returns definition base diagram PNG).
  3. Network or decoding errors (displays a graceful error card with a retry button, never crashing the UI).

### E. Dark Liquid Glass Aesthetic
- Maintain the unified dark glassmorphism design:
  - Deep dark background: `AppTheme.darkBackground` (`#0B0E14`)
  - Glass cards and sheets: `liquid_glass_easy` with specular highlight borders and subtle shadow
  - Buttons: Use `CustomOrbButton` / `OrbLoadingButton` for primary submission or action triggers.

### F. Zero Test Breakages
- Running `flutter test` must always pass 100% of the tests without errors before committing or concluding work.

---

## 📚 4. Specialized Workspace Skill

This repository includes a specialized Antigravity / AI Agent skill:

| Skill | Path | Description |
| :--- | :--- | :--- |
| **`staffpulse-frontend`** | [.agents/skills/staffpulse-frontend/SKILL.md](.agents/skills/staffpulse-frontend/SKILL.md) | Full architectural specifications, BLoC state conventions, UI component guidelines, and API contract details. |

When performing tasks related to StaffPulse Frontend, activate and follow the instructions in that skill.
