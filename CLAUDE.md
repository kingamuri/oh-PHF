# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow Orchestration

### Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately — don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes — don't over-engineer
- Challenge your own work before presenting it

### Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests — then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

- **Plan First:** Write plan to `tasks/todo.md` with checkable items
- **Verify Plan:** Check in before starting implementation
- **Track Progress:** Mark items complete as you go
- **Explain Changes:** High-level summary at each step
- **Document Results:** Add review section to `tasks/todo.md`
- **Capture Lessons:** Update `tasks/lessons.md` after corrections

## Core Principles

- **Simplicity First:** Make every change as simple as possible. Impact minimal code.
- **No Laziness:** Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact:** Changes should only touch what's necessary. Avoid introducing bugs.

## Build & Run

```bash
# Generate/regenerate Xcode project (after modifying project.yml)
xcodegen generate

# Resolve Swift packages
xcodebuild -resolvePackageDependencies -project Qonveox.xcodeproj -scheme Qonveox

# Build for simulator
xcodebuild -project Qonveox.xcodeproj -scheme Qonveox -destination 'platform=iOS Simulator,name=iPhone 16' build

# Open in Xcode
open Qonveox.xcodeproj
```

## Architecture

**Pattern:** MVVM with SwiftUI. Views own ViewModels via `@StateObject`. Services injected via `.environmentObject()`.

**Auth flow (RootView):** `isLoading` → `LoginView` (no firebase user) → `ProfileSetupView` (no app user profile) → `MainTabView` (fully authenticated).

**Navigation:** Tab-based — Cases (inbox/sent toggle), Connections, Profile. Each tab has its own `NavigationStack`.

**Data layer:** Firebase Firestore for structured data, Firebase Storage for file uploads. Models use `@DocumentID` and `Codable` for direct Firestore mapping.

**Key models:**
- `AppUser` — doctor profile (both referrer and receiver role)
- `ReferralCase` — patient case with status workflow (submitted → in_review → scheduled → completed)
- `Connection` — doctor-to-doctor link (query with two queries, merge client-side)
- `CaseFile` — file attachment (supports both `storagePath` for direct uploads and `externalURL` for WeTransfer/Smash links)

**Project generation:** Uses XcodeGen (`project.yml`). Run `xcodegen generate` after any project structure changes.

**Firebase setup:** Requires `GoogleService-Info.plist` in `Qonveox/` directory (not committed to git — obtain from Firebase Console).
