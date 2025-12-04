# TYLER OS LOG APP — v4.2.1

A personal logging engine for money, habits, crypto, and creative ideas — optimized for PowerShell 7 and EXE builds.

---

## 🧩 Overview

**TYLER OS LOG APP** is your lightweight personal operating system module for tracking daily inputs across 4 domains:

- **💵 Money** — income, expenses, categories, memos  
- **🏋️ Habits / Workouts** — habit name, duration, mood, notes  
- **₿ Crypto Activity** — buys/sells, DCA, yield, memo, auto-price from CoinGecko  
- **🎨 Creative Ideas** — bits, jokes, projects, music ideas, anything  

All logs are stored in structured **CSV files in AppData**, making the app portable, EXE-friendly, and immune to execution policy restrictions.

Version **4.2.1** includes the final fix for PowerShell 7’s TryParse issues and improves dashboard filtering reliability.

---

## 📂 AppData Structure

All logs live here:

```
%LOCALAPPDATA%\TylerLog\
    data\
        money.csv
        habits.csv
        crypto.csv
        creative.csv

    export\
        (generated CSV exports)

    backups\
        (timestamped backup folders)
```

This ensures:

- Scripts can run from **any folder**  
- **EXE builds** work with no sandbox path issues  
- Logs persist across versions

---

## 🚀 Features (4.2.1)

### ✔ PowerShell 7–safe date filtering  
No more `TryParse` overload crashes — all timestamps use safe datetime casting.

### ✔ Crypto auto-pricing (CoinGecko API)  
Supports:  
`BTC, ETH, SOL, STX, AVAX, ADA, DOGE, LINK`

### ✔ Dashboard View (7 days)  
Displays:

- Income, expenses, net  
- Habit count + average mood  
- Crypto entries + USD total  
- Creative entries + recent 3 ideas (with details)

### ✔ Creative “Recent” section  
Always shows details:

```
[project] Log app — A log app for keeping track of activities and finances
```

### ✔ Manual backup system  
Stores copies of all CSV logs into timestamped folders.

### ✔ Export all logs  
Pushes CSV files into the `export` folder.

### ✔ Fully EXE-compatible  
Build with:

```
Invoke-ps2exe -InputFile .\TylerLog.ps1 -OutputFile .\TylerLog.exe
```

---

## 🖥️ Running the Script

**PowerShell 7+ recommended**

```
pwsh -ExecutionPolicy Bypass -File .\TylerLog.ps1
```

---

## 🔧 Menu Options

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

---

## 📊 Dashboard Example

```
=== Dashboard (Last 7 Days) ===

Money:
  Income : 200
  Expense: 75
  Net    : 125

Habits / Workouts:
  Entries : 4
  Avg mood: 7.5

Crypto:
  Entries   : 2
  Total USD : 350.12
  Recent:
    [buy] 1.2 ETH @ 2100
    [yield] 0.05 STX @ 0.73

Creative:
  Entries : 3
  Recent:
    [bit] Snow plow comedy angle — felt good during brainstorm
    [project] Log app — A log app for keeping track of activities and finances
    [song] Beat idea — reverse pad intro with low kick
```

---

## 🧱 Design Philosophy

- **Portable** — lives in AppData  
- **Structured** — CSV logs for easy export  
- **Modular** — 4 log types + dashboard  
- **Stable** — hardened against PS7 string conversion issues  
- **EXE-first** — predictable behavior in *.ps1* or *.exe*  

---

## 🏷️ Version

**TYLER OS LOG APP — 4.2.1**  
The “Zero TryParse Errors” release.

