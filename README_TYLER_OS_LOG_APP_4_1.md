# TYLER OS LOG APP — 4.1

A personal logging engine for money, habits, crypto, and creativity — built for PowerShell 7 and portable EXE mode.

## Overview

**TYLER OS LOG APP — 4.1** is a lightweight personal operating system module for tracking:

- 💵 Money (income, expenses, categories, notes)
- 🏋️ Habits / Workouts (duration, mood, notes)
- ₿ Crypto activity (buys, sells, DCA, yield, CoinGecko auto-pricing)
- 🎨 Creative ideas (podcast bits, beats, projects)

Version **4.1** introduces a full migration to AppData storage, making it stable, portable, and EXE-friendly — with clean directory structure and manual backup support.

## AppData Directory Structure

Logs and exports are stored here:

```
C:\Users\<YOU>\AppData\Local\TylerLog\
    data\
        money.csv
        crypto.csv
        habits.csv
        creative.csv

    export\
        (generated CSVs from "Export all")

    backups\
        (manual timestamped backups)
```

## Features (4.1)

### ✔ EXE-SAFE PATH HANDLING
No PowerShell path issues — works perfectly compiled as `.exe`.

### ✔ CSV LOGGING (PS7 Friendly)
Fast, reliable, compatible with modern PowerShell.

### ✔ COINGECKO AUTO-PRICE
Auto fetches USD price for supported assets:
`BTC, ETH, SOL, STX, AVAX, ADA, DOGE, LINK`

### ✔ DASHBOARD MODE
7-day summary of:
- Income, expenses, net
- Habit entries + average mood
- Crypto entries + USD totals
- Creative count

### ✔ EXPORT ALL
Exports all logs to:

```
%LOCALAPPDATA%\TylerLog\export\
```

### ✔ MANUAL BACKUP SYSTEM
Creates timestamped backups:

```
backups\YYYY-MM-DD_HH-MM-SS\
```

### ✔ CLEAN STARTUP BANNER
Displays version + log root on launch.

## Running the Script

```
pwsh -ExecutionPolicy Bypass -File .\TylerLog.ps1
```

## Compile to EXE (Optional)

```
Invoke-ps2exe -InputFile .\TylerLog.ps1 -OutputFile .\TylerLog.exe
```

Then simply:

```
./TylerLog.exe
```

## Menu Options

```
1) Money Log
2) Habit / Workout Log
3) Crypto Log (Advanced)
4) Creative Log
5) Dashboard (7 days)
6) Export all to CSV
7) Backup all logs now
Q) Quit
```

## Supported Platforms

- Windows 10 / 11
- PowerShell 7+
- PS2EXE for EXE builds

## Portability

You can place `TylerLog.exe` anywhere — logs stay safely in AppData.

## Version

**TYLER OS LOG APP — 4.1**
Stable EXE-optimized release.
