# Micro-Deck — Project Context
*Last updated: February 2026*

---

## What This Project Is

**Micro-Deck** is a minimalist mobile habit *initiation* tool — not a tracker, planner, or blocker. It helps users bridge the intention-behavior gap by reducing the friction of *starting* a habit. Built for people with ADHD, executive dysfunction, or digital burnout.

Core philosophy: **one card, two minutes, no judgment.**

---

## Key Documents

| Doc | Path | Purpose |
|---|---|---|
| PRD | `aiDocs/prd.md` | Full product requirements — features, data models, metrics, out-of-scope |
| MVP | `aiDocs/mvp.md` | Demo scope — 6 screens, core loop only, definition of done |
| Architecture | `aiDocs/architecture.md` | Tech stack, verified packages, data models, folder structure, hard constraints |
| Market Research | `ai/guides/habit-help-market-research.md` | Competitive landscape, risks, positioning |
| Changelog | `ai/changelog.md` | Changelog with brief notes about each change to the codebase |

---

## MVP Scope (Current Focus)

6 screens that prove the core loop works end-to-end:

1. **Welcome** — first launch only; app name + one-line purpose + [Let's begin]
2. **Onboarding 1A** — "What do you want to work toward?" (goal)
3. **Onboarding 1B** — "What's one tiny thing that starts it?" (action, goal shown as context)
4. **Onboarding 2** — confirmation + [Start now] / [Save for later]
5. **Timer** — full-screen countdown, pulsing dot, haptic on completion
6. **Deck View** — card list, tap to start timer, [+] to add cards

MVP is done when a user can go from cold launch to haptic completion in under 90 seconds, on a real device, without crashes.

---

## Behavior

- Whenever creating plan docs and roadmap docs, always save them in ai/roadmaps. Prefix the name with the date. Add a note that we need to avoid over-engineering, cruft, and legacy-compatibility features in this clean code project. Make sure they reference each other.
- Whenever finishing with implementing a plan / roadmap doc pair, make sure the roadmap is up to date (tasks checked off, etc). Then save the docs to ai/roadmaps/complete. Then update ai/changelog.md accordingly.

---

## Current Focus

- [ ] Set up Flutter project structure
- [ ] Build Welcome screen
- [ ] Build Onboarding flow (1A → 1B → Confirmation)
- [ ] Build Timer screen with haptic
- [ ] Build Deck View with local persistence
- [ ] End-to-end demo loop working on device

---

## What's Explicitly Out of Scope (v1 post-demo)

- Scheduling / notifications
- Pro tier / paywall
- Swipe-to-defer, archiving, Dormant Deck
- "Just One" mode
- Goal management (multiple goals)
- Adjustable timer duration
- Starter templates library
- Apple Watch, widgets, Siri integration
- Any backend, cloud sync, or social features
