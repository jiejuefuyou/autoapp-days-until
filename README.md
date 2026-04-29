# DaysUntil

[![CI](https://github.com/jiejuefuyou/autoapp-days-until/actions/workflows/ci.yml/badge.svg)](https://github.com/jiejuefuyou/autoapp-days-until/actions/workflows/ci.yml)
[![Privacy: zero data](https://img.shields.io/badge/privacy-zero%20data%20collected-blue)](PRIVACY.md)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey)]()
[![Swift](https://img.shields.io/badge/swift-5.9-orange)]()

> Count to the dates that matter. Birthdays, deadlines, holidays, anniversaries — all in one quiet list.

> 🌐 **Part of the [AutoApp portfolio](https://jiejuefuyou.github.io/)** — visit the landing page or try the [PromptVault Web Edition](https://jiejuefuyou.github.io/prompts.html) (113 AI prompts, free in browser).

The third product in the **AutoApp** experiment — an iOS portfolio of single-purpose, offline-first, privacy-respecting utilities developed end-to-end by an autonomous Claude Code agent.

## Features

- Add an event with title, date, emoji, and color
- See days-to-go (or days-ago) at a glance, sorted with future first
- Tap to edit, swipe to delete
- Eight color choices (2 free, 6 premium)
- Completely offline. No accounts, no analytics, no SDKs, no notifications, no nudges.

## Pricing

- **Free** — up to 3 events, 2 colors
- **Premium** — one-time **$2.99** non-consumable IAP — unlimited events, all 8 colors, custom emoji per event

## Tech

| Layer | Choice |
|---|---|
| UI | SwiftUI (iOS 17+) |
| State | `@Observable` macro |
| Persistence | JSON in app sandbox |
| IAP | StoreKit 2 |
| Project | XcodeGen |
| Signing | fastlane match (shared `autoapp-certs`) |
| CI/CD | GitHub Actions on `macos-15` |

## Build locally

```sh
brew install xcodegen
xcodegen generate
open DaysUntil.xcodeproj
```

## AutoApp Portfolio

Sister apps under the same rules: offline-first, one-time IAP, zero analytics SDKs:

- [AutoChoice](https://github.com/jiejuefuyou/autoapp-hello) — friction-free decision wheel
- [AltitudeNow](https://github.com/jiejuefuyou/autoapp-altitude-now) — barometric altimeter, no GPS
- [DaysUntil](https://github.com/jiejuefuyou/autoapp-days-until) — quiet countdown, no notifications
- [PromptVault](https://github.com/jiejuefuyou/autoapp-prompt-vault) — offline AI prompt manager

All four scaffolded, polished, and shipped end-to-end by **one Claude Code agent** working from a shared orchestration layer (memory + ADR + state.yml + cross-repo verifier). Open-source extraction of that toolkit is on the roadmap.

## Verify the privacy claim

```sh
nm -gU <App>.app/<App> | grep -iE 'URL|HTTP|Network'
# (no output — no networking symbols in any binary)
```

The Privacy Manifest declares zero data collection. The binary's symbol table backs it up.

## Status

Phase 0 — scaffold complete. Awaiting App Store Connect API key alongside AutoChoice + AltitudeNow.

See [PRIVACY.md](PRIVACY.md) and [SECURITY.md](SECURITY.md).
