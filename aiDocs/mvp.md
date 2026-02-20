# MVP Scope — Micro-Deck Demo
**Version:** 1.0
**Status:** Draft
**Last Updated:** February 2026
**Goal:** A working demo that proves the core loop feels right

---

## 1. What This MVP Is

A functional Flutter app that demonstrates the Micro-Deck concept end-to-end in one complete loop. This is not a feature-complete product — it is a demo capable of answering one question:

> *"Does this feel different from every other habit app I've tried?"*

If someone can go from launch to completing their first card and feel something — relief, calm, surprise at how simple it was — the demo succeeds.

---

## 2. The Demo Loop (Complete, Minimum)

Every screen in the MVP exists to serve this single path:

```
App Launch
    ↓
Welcome Screen — App name, one-line purpose, [Let's begin] (first launch only)
    ↓
Onboarding — Screen 1A: "What do you want to work toward?" (goal)
    ↓
Onboarding — Screen 1B: "What's one tiny thing that starts it?" (action)
    ↓
Onboarding — Screen 2: "Good. Let's do two minutes right now."
    ↓
Timer Screen — Full screen countdown + pulsing dot
    ↓
Completion — Haptic pulse + "That's it. You started."
    ↓
Deck View — Card appears, ready to tap again
    ↓
[User taps card from deck]
    ↓
Timer Screen → Completion → Back to Deck
```

The loop must be repeatable. A one-shot demo that can't be re-entered isn't convincing.

---

## 3. Screens In Scope

### Screen 0 — Welcome (First Launch Only)
**Purpose:** orient the user in under 5 seconds, then get out of the way

- Full screen, dark background
- App name: **Micro-Deck** — large, centered, calm weight (not bold)
- One line below: *"Start the thing you keep putting off."*
- Smaller sub-line: *"One card. Two minutes. That's it."*
- Single button: **[Let's begin →]**
- No feature list, no carousel, no "how it works" section

**Behavior:**
- Only shown on first launch — never again after onboarding is complete
- After onboarding, app opens directly to the Deck View on every subsequent launch
- No skip button — the screen is brief enough that it doesn't need one

---

### Screen 1A — Onboarding: The Goal
**Purpose:** establish the "why" before asking for the "what" — mirrors implementation intention research

- Full screen, dark background
- Prompt: *"What do you want to work toward?"*
- Sub-copy (smaller, muted): *"A goal, an area of life, anything you want more of."*
- One text input field, open-ended placeholder: *"e.g. Run more often · Sleep better · Write regularly"*
- One button: **[Next →]** — disabled until field has text
- No back button — this is the entry point post-welcome
- Keyboard opens automatically on load

**Notes:**
- Goal is stored locally and shown as context on Screen 1B and on the card in the deck
- Goal is private — never shown in notifications, never surfaced as a metric
- Duration is fixed at 2 minutes in MVP (no picker yet)

---

### Screen 1B — Onboarding: The Action
**Purpose:** translate the goal into the smallest possible starting move

- Full screen, dark background
- User's goal shown at top — smaller, muted, slightly faded (context, not focus)
  - e.g., *"Run more often"*
- Prompt below: *"What's one tiny thing that starts it?"*
- Sub-copy (smaller, muted): *"Start with a verb. Make it small enough to do right now."*
- One text input field, verb-first placeholder: *"e.g. Put on my running shoes"*
- One button: **[Let's go →]** — disabled until field has text
- Back arrow (top left) → returns to Screen 1A to edit goal

**Notes:**
- The visual hierarchy (goal above → action below) makes the goal-to-action relationship visible without explaining it
- This is the card's action label — what shows on the deck and in the timer

---

### Screen 2 — Onboarding: The Confirmation
**Purpose:** lower the stakes and get consent to start immediately

- Full screen, dark background
- Copy: *"Good. Let's do two minutes of it right now."*
- The user's typed action label shown back to them (reinforces it's theirs)
- Two options:
  - **[Start now]** — primary, proceeds to timer
  - **[Save for later]** — secondary, skips timer and goes to deck view with card added

**Notes:**
- "Save for later" must work — not everyone is ready to start immediately
- No back navigation — no second-guessing encouraged

---

### Screen 3 — Timer Screen
**Purpose:** the ritual — distraction-free, calm, just the task

- Full screen, dark background (near black — not pure #000000, slightly warm)
- Large centered countdown display: `MM:SS` — clean, generous type size
- Ambient pulsing dot below the countdown — slow, gentle pulse (not urgent)
- User's action label displayed faintly above the countdown
- Screen stays on (idle timer disabled for session duration)
- **No back gesture during active timer** — prevents accidental exits
- Tap anywhere to **pause** — tap again to **resume**
- When paused: countdown freezes, dot stops pulsing, faint **[End session]** option appears

**Completion behavior:**
- At 0:00 → haptic fires (single medium-impact pulse)
- Countdown replaced by completion phrase (see copy below)
- 2-second hold, then soft fade to completion screen

**Completion copy options (pick one for MVP, test later):**
- *"That's it."*
- *"Started."*
- *"Done."*

**Notes:**
- Haptic uses `HapticFeedback.mediumImpact()` from Flutter's `services` library — no external package needed for MVP
- No animation beyond the pulse and fade — no confetti, no score reveal, nothing

---

### Screen 4 — Deck View
**Purpose:** show the user where their card lives and invite them to use it again

- Clean list of cards — vertical stack
- Each card shows:
  - Action label (large, readable)
  - Duration badge (e.g., "2 min")
- **Tap any card** → goes directly to Timer Screen for that card
- **[+]** button in corner → opens a simple "Add a card" sheet (see below)
- First visit: the card from onboarding is already here, no empty state needed

**Empty state (if user somehow clears all cards):**
- Single centered prompt: *"Add your first card to get started."*
- [+] button prominent

**Add a card (minimal sheet for MVP):**
- Two fields matching the onboarding flow — goal (optional) then action label (required)
- Goal field is pre-filled if the user already has a goal from onboarding (editable)
- [Save] button
- No duration picker, no schedule — all fixed to 2 min in MVP

**Notes:**
- Cards are persisted locally — reopening the app shows the same deck
- No swipe-to-defer in MVP — tap only
- No reordering in MVP
- No archiving in MVP

---

## 4. Local Persistence (Required for Demo)

The demo is not convincing if cards disappear on app restart. Basic persistence is in scope.

**Approach for MVP:** use `shared_preferences` or `sqflite` directly (no need for the full `drift` setup yet).

**What gets stored:**
- Card goal label (optional, shown as context on card)
- Card action label
- Card duration (fixed at 120 seconds in MVP)
- Card creation timestamp (for ordering)
- `hasCompletedOnboarding` flag (boolean) — controls whether Welcome screen shows on launch

**What does NOT get stored in MVP:**
- Session history
- Goals
- Schedules
- Archive state

---

## 5. Out of Scope for MVP Demo

These are all confirmed PRD features — excluded here to keep the demo achievable and focused.

| Feature | When |
|---|---|
| Card scheduling + notifications | v1 post-demo |
| Multiple goals (one goal per card in MVP) | v1 post-demo |
| Adjustable timer duration | v1 post-demo |
| Swipe-to-defer | v1 post-demo |
| "Just One" mode | v1 post-demo |
| Card archiving / Dormant Deck | v1 post-demo |
| Starter templates library | v1 post-demo |
| Pro tier + paywall | v1 post-demo |
| Onboarding explainer (post-completion) | v1 post-demo |
| Notification permission request | v1 post-demo |
| Settings screen | v1 post-demo |
| App icon + splash screen | v1 post-demo |

---

## 6. Demo Script

What to show someone when demoing the app. Keep this under 3 minutes.

**Step 1 — Launch**
Open the app cold. The welcome screen appears. Read it aloud if helpful: *"Start the thing you keep putting off. One card. Two minutes."* Tap [Let's begin].

**Step 2 — Enter a real goal**
Type something genuine — not a demo placeholder. *"Exercise more"* or *"Write more often."* The realness of the goal makes Step 3 land harder.

**Step 3 — Enter a real action**
Point out that the goal is shown at the top, then the app asks for the smallest possible start. Type something tiny: *"Put on my running shoes"* or *"Open a blank doc."* This is the moment to explain the idea if needed: *"The goal stays private. The card is just the start."*

**Step 4 — Hit "Let's go" then "Start now"**
Let the timer run. Don't explain it. Let the person watch the dot pulse. The silence is part of the demo.

**Step 5 — Feel the haptic**
When it completes, hand them the phone if possible so they feel the haptic themselves. This is the moment.

**Step 6 — Show the deck**
After completion, the card is sitting in the deck with the goal shown faintly below the action label. Tap it again. Run another 2 minutes. Show that the loop is repeatable.

**What to say after:**
*"That's it. No streak. No score. It just helped you start."*

---

## 7. MVP Definition of Done

The MVP demo is complete when:

- [ ] Welcome screen appears on first launch only — never again after onboarding
- [ ] Onboarding: goal field (Screen 1A) captures input and passes it to Screen 1B
- [ ] Onboarding: Screen 1B shows the user's goal as faded context above the action field
- [ ] User completes full onboarding in under 90 seconds
- [ ] Timer screen fills the full screen with no distracting UI chrome
- [ ] Haptic fires on timer completion on a real device
- [ ] Card appears in deck after onboarding, showing both action label and goal context
- [ ] Tapping a deck card opens the timer for that card
- [ ] Cards persist after closing and reopening the app
- [ ] "Save for later" path works (skips timer, goes to deck)
- [ ] Adding a second card from the deck captures goal + action
- [ ] No crashes on the demo path on a physical device or emulator

---

## 8. Open Questions for MVP

1. **Warm dark background color:** slightly warm near-black (e.g., `#0F0E0D`) vs. cool near-black (e.g., `#0D0D0F`) — affects the entire emotional tone. Decide before building timer screen.
2. **Completion phrase:** *"That's it."* vs. *"Started."* vs. *"Done."* — pick one for MVP, validate with real users later.
3. **Pulse animation style:** slow sine-wave opacity pulse vs. slow scale pulse — needs a quick prototype to feel right before committing.
4. **"Save for later" destination:** land on deck view immediately, or show a brief confirmation first?
5. **Goal field on Screen 1A — required or optional?** Making it optional lowers friction but weakens the goal→action relationship that makes the product meaningful. Recommended: required in onboarding, optional when adding subsequent cards from the deck.
6. **Welcome screen button label:** *"Let's begin →"* vs. *"Get started"* vs. *"Start here"* — small copy choice, sets the tone immediately.
