<div align="center">

<br/>

# ☕ Beans & Bites

**Your personal coffee ritual, perfected.**

*A premium iOS app for specialty coffee lovers — guided brews, taste tracking, food pairings, and a community built around the craft.*

`Swift 5` &nbsp;·&nbsp; `SwiftUI` &nbsp;·&nbsp; `SwiftData` &nbsp;·&nbsp; `MVVM` &nbsp;·&nbsp; `iOS 17+` &nbsp;·&nbsp; `Fully Offline`

<br/>

</div>

---

## The Problem

You buy specialty coffee. It costs ₹800 a bag. The label says *"blueberry notes, jasmine finish."*

You brew it. It tastes like regret.

Ratio — wrong. Grind — wrong. Water temperature — guessing. Bloom time — what's that?

That information exists. It's scattered across YouTube, Reddit threads, and barista training manuals that no one reads. **Beans & Bites puts it all in your pocket.**

---

## What It Does

| Feature | Description |
|---|---|
| **Guided Brew Sessions** | Step-by-step timers for 8 methods — Pour Over, Espresso, French Press, V60, AeroPress, Cold Brew, Latte, Flat White |
| **Recipe Creation** | Build and save fully custom recipes with photos, tasting notes, and brew parameters |
| **Smart Food Pairing** | Curated pairings matched to bean origin and roast level — know what snack goes with your kaapi |
| **SCA Flavor Wheel** | Log tasting notes after every session using the Specialty Coffee Association standard wheel |
| **Taste Profile** | A radar chart that grows from your brew history — see your palate evolve over time |
| **Community** | Official and user-created channels — Daily Chat, Origin & Terroir, Monthly Contests, Pairings |
| **Fully Offline** | No account required. No server calls. Everything runs and persists on-device |

---

## Screens

<div align="center">

| Home | Brew | Timer | Community |
|:---:|:---:|:---:|:---:|
| Today's ritual, methods, barista assistant | Filter and search the recipe catalog | Live phase timer with step instructions | Channels and ritual feed |

</div>

---

## Tech Stack

```
┌─────────────────────────────────────────────────┐
│               SwiftUI Views                     │
│   Home · Brew · Community · Profile · History   │
├─────────────────────────────────────────────────┤
│        ViewModels  (Combine + MVVM)             │
│      AppDataStore — single source of truth      │
├─────────────────────────────────────────────────┤
│            Data Model Managers                  │
│   Coffee · Brew · Community · Profile · Auth    │
├─────────────────────────────────────────────────┤
│              Persistence Layer                  │
│         SwiftData (SQLite)  +  JSON             │
├─────────────────────────────────────────────────┤
│           Supporting Services                   │
│  Swift Charts · Canvas/Path · UIKit Haptics     │
│         CoffeeTheme Design System               │
└─────────────────────────────────────────────────┘
```

| Layer | Technology |
|---|---|
| UI | Swift 5 + SwiftUI |
| State | Combine, MVVM, AppDataStore |
| Persistence | SwiftData (SQLite on-device) |
| Charts | Swift Charts + custom Canvas/Path |
| Flavor Wheel | SCA-standard, built with Canvas + Path |
| Haptics | UIKit Haptics API |
| Data | Codable + JSON (offline catalog) |
| Version Control | Git |

---

## Project Structure

```
Beans&Bites/
├── Features/
│   ├── Brew/          # Brew flow, timer, SCA wheel, recipe creation
│   ├── History/       # Past sessions and detail views
│   ├── Home/          # Today screen, featured ritual, barista assistant
│   ├── Insights/      # Taste radar and brew analytics
│   ├── Onboarding/    # First-run experience
│   └── Profile/       # User profile, achievements, settings
├── Core/
│   └── Storage/       # SwiftData entities and persistence managers
├── Data Models/       # Swift structs for all domain types
├── UI/                # Shared screens — BrewDetail, Community, CreateRecipe
├── Sample Data/       # JSON fixtures for coffee, brews, pairings, discover
└── Assets.xcassets/   # App icons, ritual images, design assets
```

---

## Getting Started

1. **Clone** the repo and open `Beans-Bites.xcodeproj` in Xcode 15+
2. Select the **iPhone 17 Pro** simulator (or any iOS 17+ device)
3. **Build and run** — no API keys, no backend setup, no configuration needed

> The app loads with a full set of sample rituals, pairings, and community channels out of the box.

---

## The Team

Built over **8 weeks** as an Exploratory Project at Chitkara University, Punjab.

| Name | Role |
|---|---|
| Saurabh Singh | Lead Developer |
| Seerat Sharma | UI/UX & Features |
| Driksha Thakur | Features & Architecture |
| Mahi Awasthi | Data Modeling & Community |

**Supervised by** Dr. Swati Goel

---

## Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, reviewed code |
| `drix` | Driksha's feature branch |

---

<div align="center">

*Built with caffeine, patience, and an unreasonable love for specialty coffee.*

</div>
