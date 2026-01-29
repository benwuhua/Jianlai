# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a HarmonyOS (OpenHarmony) native mobile application built with ArkTS (TypeScript-based declarative language) and targeting HarmonyOS SDK API 6.0.2 (API Level 22).

**Key Technology:**
- Language: ArkTS (`.ets` files)
- Build System: Hvigor (HarmonyOS build tool)
- Package Manager: OHPM (OpenHarmony Package Manager)
- UI Framework: ArkUI (declarative UI)
- Architecture: Stage Model (current HarmonyOS architecture)

## Build and Development Commands

**Prerequisite:** This project requires DevEco Studio (Huawei's official IDE for HarmonyOS development). While some commands can run via CLI, full development requires the IDE.

```bash
# Build the application (debug mode)
hvigorw assembleHap

# Build release version
hvigorw assembleHap --mode release

# Run local unit tests (no device required)
hvigorw test

# Run instrumentation tests (requires device/emulator)
hvigorw testOhos
```

**Note:** The project uses Hvigor build system. Output artifacts are placed in `.hvigor/outputs/`.

## Architecture

### Stage Model Structure

This application uses the HarmonyOS Stage Model (not the older FA Model):

- **EntryAbility** (`entry/src/main/ets/entryability/EntryAbility.ets`): Main application entry point extending `UIAbility`. Manages app lifecycle (`onCreate`, `onDestroy`, `onWindowStageCreate`, `onForeground`, `onBackground`).

- **EntryBackupAbility** (`entry/src/main/ets/entrybackupability/EntryBackupAbility.ets`): Backup extension ability extending `BackupExtensionAbility`. Implements `onBackup()` and `onRestore()` for data persistence.

- **Pages** (`entry/src/main/ets/pages/`): UI components using ArkUI declarative syntax. The main page is `Index.ets`.

### Module Organization

- **AppScope**: Application-level configuration (`app.json5`, app-level resources)
- **entry**: Main application module (HAP - HarmonyOS Ability Package)
  - `src/main/ets/`: ArkTS source code
  - `src/test/`: Local unit tests (run without device)
  - `src/ohosTest/`: Instrumentation tests (require device/emulator)
  - `build-profile.json5`: Module build configuration
  - `module.json5`: Module metadata and abilities manifest

### Resource System

Resources use `$type:name` reference syntax:
- `$string:resource_name` - String resources
- `$color:resource_name` - Color resources
- `$float:resource_name` - Dimension resources
- `$media:resource_name` - Images and icons

Resource directories:
- `base/` - Default resources
- `dark/` - Dark theme resources
- Additional qualifiers can be added (resolution, country, etc.)

### Import Pattern

HarmonyOS uses Kit-based imports:
```typescript
import { UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BackupExtensionAbility } from '@kit.CoreFileKit';
```

### Declarative UI Components

Pages use `@Entry` and `@Component` decorators:
- `@State` for reactive state management
- Event handlers (e.g., `.onClick()`)
- Layout components (e.g., `RelativeContainer`, `Column`, `Row`)

## Testing

**Test Structure:**
- Local unit tests in `entry/src/test/`
- Instrumentation tests in `entry/src/ohosTest/`
- Testing framework: `@ohos/hypium` v1.0.25
- Mocking framework: `@ohos/hamock` v1.0.0

**Test Pattern:**
```typescript
describe('testSuite', () => {
  beforeAll(() => { /* setup */ });
  it('testName', 0, () => { /* test */ });
  afterAll(() => { /* cleanup */ });
});
```

## Configuration Files

- **AppScope/app.json5**: App-level metadata (bundle name, version, vendor, icon)
- **entry/src/main/module.json5**: Module configuration (abilities, pages, device types)
- **build-profile.json5**: Build settings (targets, mode, obfuscation)
- **code-linter.json5**: Linting rules with security checks for crypto operations
- **hvigor-config.json5**: Hvigor build tool configuration

## Logging

The project uses `hilog` for logging with consistent pattern:
```typescript
const DOMAIN = 0x0000;
hilog.info(DOMAIN, 'testTag', '%{public}s', 'message');
hilog.error(DOMAIN, 'testTag', 'Failed: %{public}s', JSON.stringify(err));
```

## App Metadata

- Bundle ID: `com.ryan.myapplication`
- Version: `1.0.0` (version code: 1000000)
- Target Device: Phone
- API Type: Stage Mode
