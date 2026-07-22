# Mobile Validation Report

**Date:** 2026-07-13  
**Status:** BLOCKED_NO_PHYSICAL_DEVICE

## Build Evidence

- Flutter analyze: no issues.
- Flutter tests: 41 passed.
- APK release: passed, 57,891,679 bytes.
- App Bundle release: passed after installing the official Android command-line
  tools package and verifying its published SHA-1 checksum.
- App Bundle: 57,806,855 bytes.

## Device Evidence

`flutter devices` reported only Windows, Chrome and Edge. No Android physical
device was connected. Therefore login, course, player, download, profile,
subscription cancellation, certificates, logout, offline behavior, render and
FPS could not be truthfully approved on hardware.

The Android toolchain also reports a future compatibility warning from
`workmanager_android` using the Kotlin Gradle Plugin. It does not fail current
release builds and is tracked as technical debt.

