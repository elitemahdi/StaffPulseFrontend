---
name: staffpulse-frontend
description: >-
  Comprehensive architecture, BLoC conventions, Liquid Glass UI guidelines, API contracts,
  and testing workflows for StaffPulse Frontend. Use this skill whenever building, modifying,
  testing, or debugging Flutter screens, BLoCs, repositories, or components in the StaffPulse Flutter app.
---

# StaffPulse Frontend Engineering Skill

This skill contains the authoritative runbook, architectural specifications, and implementation guidelines for developing and maintaining the **StaffPulse Flutter Application**.

---

## 1. Architecture & Directory Blueprint

StaffPulse Frontend is organized around feature modules and core shared infrastructure:

```text
StaffPulseFrontend/lib/
├── main.dart                                 # App bootstrap, Theme, Router, Toast provider
├── core/
│   ├── configs/
│   │   ├── colors.dart                       # Design system semantic palettes (AntD & Apple inspired)
│   │   └── constants.dart                    # Timeouts, storage keys, endpoints, base URL fallback
│   ├── model_serializer/                     # JSON serialization models (User, Leave, Task, SSE Event)
│   ├── services/
│   │   ├── api_client.dart                   # Dio HTTP client, Bearer interceptor, DataState wrapper
│   │   ├── app_toast.dart                    # AwesomeToast wrapper for success, error, warning, info
│   │   ├── global_controller.dart            # Active user session and token broadcast
│   │   ├── locator.dart                      # GetIt service locator (singletons, factories)
│   │   ├── router.dart                       # GoRouter route declarations and navigation keys
│   │   ├── storage_service.dart              # SharedPreferences abstraction
│   │   └── theme.dart                        # Dark Liquid Glass theme configuration
│   ├── utils/
│   │   ├── bloc_states.dart                  # Standardized BLoC state abstractions
│   │   ├── data_state.dart                   # DataSuccess<T> and DataFailed<T> result types
│   │   └── status_management_widget.dart     # Loading / Error / Empty / Content view switcher
│   └── widget/components/
│       └── custom_orb_button.dart            # Apple Liquid Glass button with 9-state ThinkingOrb
├── home/
│   └── presentation/screens/home_screen.dart # Dashboard, balance glance, feature tiles
├── leave/
│   ├── presentation/
│   │   ├── controller/                       # LeaveSubmitBloc, ManagerTasksBloc, LeaveHistoryBloc
│   │   ├── screens/                          # LeaveRequestScreen, ManagerTasksScreen, LeaveHistoryScreen
│   │   └── widgets/
│   │       ├── process_diagram_sheet.dart    # Live Flowable BPMN 2.0 diagram viewer
│   │       └── rag_thinking_sheet.dart       # Real-time RAG SSE thinking stream modal
│   └── repository/leave_repository.dart      # Leave submission, tasks, history, diagram API calls
├── login/
│   ├── presentation/                         # LoginScreen, LoginBloc, LoginEvent, LoginState
│   ├── repository/auth_repository.dart       # Token retrieval, storage, and validation
│   └── models/                               # LoginMapper and UserUiModel
├── splash/
│   ├── presentation/                         # SplashScreen and SplashBloc
│   └── repository/splash_repository.dart     # Auto-login and session validation
└── l10n/                                     # RTL Persian (primary) and English localizations
```

---

## 2. Core Implementation Patterns

### A. State Management with BLoC
Every interactive feature follows the strict **Event $\rightarrow$ BLoC $\rightarrow$ State** lifecycle:
1. **Events:** Immutable classes extending `Equatable` representing user actions (e.g., `FetchPendingTasksEvent`, `SubmitLeavePromptEvent`).
2. **States:** Immutable classes extending `Equatable` representing distinct UI states (`Initial`, `Loading`, `Success`, `Error`).
3. **BLoC:** Handles business logic and calls repositories via `emit(...)`.
4. Always register BLoCs as `Factory` in `locator.dart`:
   ```dart
   locator.registerFactory<ManagerTasksBloc>(
     () => ManagerTasksBloc(
       leaveRepository: locator<ILeaveRepository>(),
       globalController: locator<GlobalController>(),
     ),
   );
   ```

### B. Networking & Unified Error Handling (`DataState<T>`)
- All repository methods **MUST** return `Future<DataState<T>>` to prevent unhandled Dio exceptions:
  ```dart
  try {
    final response = await apiClient.post('/leave/submit', data: payload);
    return DataSuccess(LeaveRequestSerializer.fromJson(response.data));
  } on DioException catch (e) {
    return DataFailed(e.message ?? 'Server error occurred');
  } catch (e) {
    return DataFailed(e.toString());
  }
  ```
- `ApiClient` automatically injects the Bearer token from `GlobalController` on every request.

### C. Real-Time Server-Sent Events (SSE) Streaming
When submitting conversational leave requests:
- Endpoint: `POST /api/v1/leave/submit-stream`
- Response Type: `ResponseBody.fromString(...)` with chunk stream decoding.
- Events handled by `LeaveSubmitBloc`:
  - `rag_chunk`: Reasoning and policy context fragments appended live to `RagThinkingSheet`.
  - `evaluation_complete`: AI recommendation (`AUTO_APPROVE`, `UNIT_MANAGER_REVIEW`, etc.) and risk score.
  - `completed`: Final `LeaveRequest` record with status and process instance ID.
  - `error`: Explanatory Persian error messages.

---

## 3. UI/UX & Liquid Glass Conventions

### A. Apple Liquid Glass Design Language
- **Backgrounds:** Always use `AppTheme.darkBackground` (`#0B0E14`).
- **Cards & Sheets:** Use `LiquidGlassEasy` with subtle borders (`accentColor.withValues(alpha: 0.35)`).
- **Primary Buttons:** Always use `CustomOrbButton` (alias `OrbLoadingButton`) with tactile haptic feedback:
  ```dart
  CustomOrbButton(
    text: 'ثبت و ارسال به هوش مصنوعی',
    orbState: OrbState.evaluating,
    isLoading: state is LeaveSubmitLoading,
    onPressed: () => context.read<LeaveSubmitBloc>().add(SubmitLeavePromptEvent(text)),
  )
  ```

### B. BPMN Diagram Viewer (`ProcessDiagramSheet`)
- Fetches `image/png` from `/leave/process-instances/{process_instance_id}/diagram`.
- Handles active instances (highlighted active token) and completed instances (process baseline diagram).
- Provides interactive zoom (`InteractiveViewer`), full-screen toggle, refresh, and error retry states.

---

## 4. Non-Negotiable Invariants & Rules

1. **Anti-Self-Approval UI Guard:**
   - In `ManagerTasksScreen`, if `task.applicantEmployeeCode == currentUser.employeeCode`:
     - Display a prominent amber badge: *"درخواست خود کاربر"*.
     - **DISABLE** the Approve and Reject action buttons.
2. **Mandatory RTL Persian Wrapping:**
   - Wrap views and modal bottom sheets in `Directionality(textDirection: TextDirection.rtl)`.
3. **No Direct Network Calls in Presentation Layer:**
   - Widgets must never instantiate `Dio` or call `ApiClient` directly. All data must flow through Repositories and BLoCs.
4. **Clean Code & Test Coverage:**
   - Always run `flutter test` after modifying any BLoC, repository, or widget.
   - All 40 unit and BLoC tests must pass before pushing code.

---

## 5. Verification Commands

```bash
# Verify all unit, BLoC, and widget tests
flutter test

# Run code analysis
flutter analyze

# Launch on Chrome
flutter run -d chrome
```
