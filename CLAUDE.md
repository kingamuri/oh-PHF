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

# Build for generic iOS (no code signing)
# Note: Use symlink to avoid shell escaping issues with "!" in path
ln -sf "/Users/amuri/Desktop/oh! PHF" /tmp/ohphf_build
xcodebuild -project /tmp/ohphf_build/OhPHF.xcodeproj -scheme OhPHF \
  -destination generic/platform=iOS \
  CODE_SIGNING_ALLOWED=NO \
  IPHONEOS_DEPLOYMENT_TARGET=18.0 \
  build

# Open in Xcode
open "OhPHF.xcodeproj"
```

## Architecture

**Pattern:** MVVM with SwiftUI. Views own ViewModels via `@StateObject`. Services injected via `.environmentObject()`.

**App flow:** WelcomeView (language select + patient number) → 8 form pages → ConsentsView (signature + submit) → PDF → Email → Reset.

**Navigation:** Page-based form flow managed by `FormViewModel.currentPage`. Conditional page skipping (Women's Health only for female patients). BDD screener only for aesthetic visit reasons.

**Localization:** Runtime language switching via `LocalizationManager` singleton. `L(_:)` global helper reads from `.lproj/Localizable.strings` bundles. 4 languages: DE, EN, RU, AR (RTL).

**Key models:**
- `PatientForm` — single Codable struct with nested types for each form page
- `ClinicSettings` — clinic configuration persisted via UserDefaults (JSON encoded)
- `BDDScorer` — Body Dysmorphic Disorder screening (7 questions, 0-21 score, color-coded risk levels)

**Services:**
- `PDFGeneratorService` — A4 PDF generation via `UIGraphicsPDFRenderer`
- `EmailComposerView` — `MFMailComposeViewController` wrapper for sending PDF
- `PDFStorageService` — FileManager-based rolling buffer (last 50 PDFs)

**Project generation:** Uses XcodeGen (`project.yml`). Run `xcodegen generate` after any project structure changes.

**Kiosk mode:** Idle timer disabled, status bar hidden, long-press logo (3s) → PIN entry → Settings. Default PIN: "1234".
