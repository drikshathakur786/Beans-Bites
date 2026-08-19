# Swift Student Challenge Prioritization

## Goal
Ship a polished, coherent, offline-capable experience that can be fully understood in under 3 minutes.

## Must Ship (P1)
- Onboarding flow: welcome, taste, equipment, skill, account handoff
- Home dashboard: recommendation, streak, quick log, progress snapshot
- Brew flow: method -> setup -> guided steps -> taste log -> save
- Brew history + detail
- Profile basics: level, XP, streak, total brews, favorite method, saved rituals
- Reliable local persistence with sample data fallback
- Accessibility baseline (dynamic type support, clear labels, contrast-safe controls)

## Should Ship (P2)
- Insights screen (weekly chart + flavor preference radar approximation)
- Smart suggestions in Home based on previous logs
- Save as template from taste log + brew again from detail

## Nice To Have (P3)
- Community feed with structured post metadata
- Weekly challenges and basic leaderboard UI
- Badge wall / achievements expansion

## Defer After Submission (P4)
- Masterclass content/video
- Bean explorer world map
- Ritual templates marketplace

## Demo Script (Recommended)
1. Onboarding personalization (10-15 sec)
2. Home recommendation and streak (20 sec)
3. Full brew flow including guided timer and taste log (70 sec)
4. Brew history and detail with brew-again (30 sec)
5. Profile progression (15 sec)

## Acceptance Criteria
- No dead-end navigation
- Every primary button updates visible state
- App works without network
- Data survives relaunch
- No placeholder crash paths
