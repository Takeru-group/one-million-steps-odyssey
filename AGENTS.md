# AI Development Guidelines

## 1. Directory Structure Principles
Follow Separation of Concerns (MVC/Feature-based):
- `models/`: Data models & serialization
- `views/` or `pages/` or `widgets/`: UI components & layouts
- `controllers/` or `repositories/` or `services/` or `managers/`: Business logic, Firestore, AdMob, StepTracker
- `utils/` or `helpers/`: Common utilities & constants
- `l10n/`: Localization

## 2. File Modification & Execution Rules
- Directly apply code changes and file updates using Antigravity tools (no need to output full file code blocks in chat for manual copy-pasting).
- Never revert or remove established production IDs or working features without explicit instructions.
- Ensure static analysis (`dart analyze`) remains clean and does not introduce regressions after edits.

## 3. Production Configuration
- AdMob Units: Always preserve the assigned production IDs for iOS/Android (Rewarded & Interstitial).
- Maintain Single Source of Truth for ad loading states via `AdManager`.

## 4. Event Priority Chain
1. Era Unlocked / Transition Dialog (Highest)
2. Century Change Action (InAppReview for Century -6, 1, 8, 16; InterstitialAd for others)
3. Step Milestone Dialogs (6,000 steps first, 10,000 steps second)