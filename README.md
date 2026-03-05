# CycleTracker

A period tracking app for iOS built with SwiftUI. Designed to feel like a supportive companion rather than a medical form — soft UI, friendly characters, and gentle phase-aware suggestions.

## Features

**Today tab**
- Daily quote seeded per day, rotating without repeating
- One do and one don't for the day, phase-specific
- Explanation of what your body is doing hormonally
- Phase-specific food recommendations and seed cycling suggestions
- 15 vegetarian recipes per phase loaded from local JSON
- Blob character with phase-matching expression and chef hat on the recipes section

**Calendar tab**
- Full month calendar with phase-colored days
- Connected pill indicator for consecutive period days
- Tap any day to see its phase
- Add and manage period start dates

**Throughout**
- The entire app shifts color depending on your current cycle phase
- SwiftUI-drawn blob characters with different expressions per phase
- Phase selector to browse any phase's content

## Tech Stack

- Swift & SwiftUI
- SwiftData
- MVVM architecture
- Local JSON content (no backend or API keys required)

## Built With

- [Warp](https://www.warp.dev) — AI-assisted code generation
- [Claude](https://claude.ai) — UI design & content

## Project Structure

```
CycleTracker/
├── Models/
│   ├── CycleRecord.swift                   # SwiftData model
│   ├── CyclePhase.swift                    # Phase enum with colors
│   └── CycleCalculator.swift               # Phase calculation logic
├── ViewModels/
│   ├── CycleViewModel.swift
│   └── CalendarViewModel.swift
├── Views/
│   ├── PhaseRecommendationsView.swift      # Today tab
│   └── CalendarView.swift                  # Calendar tab
├── Components/
│   └── PhaseBlobCharacterView.swift        # SwiftUI-drawn blob characters
└── Resources/
    └── PhaseContent.json                   # All quotes, recipes, foods, tips
```
