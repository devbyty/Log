
# TYLER OS LOG APP — 4.1
# EXE-safe, PS7-friendly, AppData-based logger with manual backups

# Resolve base app directory in LocalAppData (works for .ps1 and .exe)
$LocalAppData = [Environment]::GetFolderPath('LocalApplicationData')
$AppRoot     = Join-Path $LocalAppData "TylerLog"
$DataDir     = Join-Path $AppRoot "data"
$ExportDir   = Join-Path $AppRoot "export"
$BackupRoot  = Join-Path $AppRoot "backups"

# Ensure core directories exist
foreach ($dir in @($AppRoot, $DataDir, $ExportDir, $BackupRoot)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

function Get-LogPath {
    param([string]$Name)
    return (Join-Path $DataDir ("{0}.csv" -f $Name))
}

function Read-Decimal {
    param([string]$Prompt)
    while ($true) {
        $input = Read-Host $Prompt
        if ([string]::IsNullOrWhiteSpace($input)) { return $null }
        $tmp = 0.0
        if ([decimal]::TryParse($input, [ref]$tmp)) {
            return [decimal]$input
        }
        Write-Host "Please enter a valid number or leave blank." -ForegroundColor Yellow
    }
}

function Read-Int {
    param([string]$Prompt)
    while ($true) {
        $input = Read-Host $Prompt
        if ([string]::IsNullOrWhiteSpace($input)) { return $null }
        $tmp = 0
        if ([int]::TryParse($input, [ref]$tmp)) {
            return [int]$input
        }
        Write-Host "Please enter a valid whole number or leave blank." -ForegroundColor Yellow
    }
}

function Get-PriceFromCoinGecko {
    param([string]$Asset)

    $map = @{
        "BTC" = "bitcoin"
        "ETH" = "ethereum"
        "SOL" = "solana"
        "STX" = "stacks"
        "AVAX" = "avalanche-2"
        "ADA" = "cardano"
        "DOGE" = "dogecoin"
        "LINK" = "chainlink"
    }

    if ([string]::IsNullOrWhiteSpace($Asset)) { return $null }

    $sym = $Asset.ToUpper()
    if (-not $map.ContainsKey($sym)) {
        Write-Host "Asset $sym is not configured for auto-price. Enter manually if you like." -ForegroundColor Yellow
        return $null
    }

    $id  = $map[$sym]
    $url = "https://api.coingecko.com/api/v3/simple/price?ids=$id&vs_currencies=usd"

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 10
        $price = $response.$id.usd
        if ($price -ne $null -and $price -gt 0) {
            Write-Host ("Auto price from CoinGecko: ${0}" -f $price) -ForegroundColor Green
            return [decimal]$price
        } else {
            Write-Host "CoinGecko returned no usable price." -ForegroundColor Yellow
            return $null
        }
    } catch {
        Write-Host "CoinGecko request failed (rate limit, offline, or blocked)." -ForegroundColor Yellow
        return $null
    }
}

function Append-CsvRow {
    param(
        [string]$Name,
        [hashtable]$Row
    )

    $path = Get-LogPath -Name $Name
    $obj  = New-Object PSObject -Property $Row

    if (-not (Test-Path $path)) {
        $obj | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
    } else {
        $obj | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8 -Append
    }
}

function Get-Log {
    param([string]$Name)

    $path = Get-LogPath -Name $Name
    if (-not (Test-Path $path)) { return @() }

    try {
        $data = Import-Csv -Path $path
        return @($data)
    } catch {
        Write-Host "Failed to read $Name log from $path" -ForegroundColor Yellow
        return @()
    }
}

function Log-Money {
    Write-Host ""
    Write-Host "=== Money Log ===" -ForegroundColor Cyan
    Write-Host "Use for income, bills, spending, subscriptions, etc."
    Write-Host ""

    $typeInput = Read-Host "Type: I = Income, E = Expense"
    $kind = switch ($typeInput.ToUpper()) {
        "I" { "income" }
        "E" { "expense" }
        default { "expense" }
    }

    $amount = $null
    while ($null -eq $amount) {
        $amount = Read-Decimal "Amount in USD"
        if ($null -eq $amount) {
            Write-Host "Amount is required." -ForegroundColor Yellow
        }
    }

    $category = Read-Host "Category (eg paycheck, rent, food, brewery, fun)"
    if ([string]::IsNullOrWhiteSpace($category)) { $category = "uncategorized" }

    $memo = Read-Host "Memo (optional)"

    $row = @{
        timestamp = (Get-Date).ToString("s")
        type      = $kind
        amount    = $amount
        category  = $category
        memo      = $memo
    }

    Append-CsvRow -Name "money" -Row $row
    Write-Host "Money entry saved." -ForegroundColor Green
}

function Log-Habit {
    Write-Host ""
    Write-Host "=== Habit / Workout Log ===" -ForegroundColor Cyan
    Write-Host "Use for gym sessions, walks, sleep tracking, etc."
    Write-Host ""

    $habit = Read-Host "Habit name (eg gym, walk, pull-ups, sleep)"
    if ([string]::IsNullOrWhiteSpace($habit)) { $habit = "habit" }

    $duration = Read-Int "Duration in minutes (optional)"
    $mood     = Read-Int "Mood 1-10 (optional)"
    $memo     = Read-Host "Memo (what you did or how it felt, optional)"

    $row = @{
        timestamp = (Get-Date).ToString("s")
        habit     = $habit
        duration  = $duration
        mood      = $mood
        memo      = $memo
    }

    Append-CsvRow -Name "habits" -Row $row
    Write-Host "Habit entry saved." -ForegroundColor Green
}

function Log-Crypto {
    Write-Host ""
    Write-Host "=== Advanced Crypto Log ===" -ForegroundColor Cyan
    Write-Host "Tracks buys, sells, DCA, and yield with optional auto-price."
    Write-Host ""

    $actionInput = Read-Host "Action: B = Buy, S = Sell, D = DCA, Y = Yield, O = Other"
    $action = switch ($actionInput.ToUpper()) {
        "B" { "buy" }
        "S" { "sell" }
        "D" { "dca" }
        "Y" { "yield" }
        "O" { "other" }
        default { "other" }
    }

    $asset = Read-Host "Asset symbol (eg BTC, ETH, SOL, STX)"
    if ([string]::IsNullOrWhiteSpace($asset)) { $asset = "UNKNOWN" }

    $exchange = Read-Host "Exchange or platform (eg Coinbase, OKX, Ether.fi, Wallet)"
    $location = Read-Host "Wallet or account name (optional)"

    $useAuto  = Read-Host "Use auto CoinGecko price? (Y = yes, N = manual)"
    $priceUsd = $null

    if ($useAuto.ToUpper() -eq "Y" -or [string]::IsNullOrWhiteSpace($useAuto)) {
        $priceUsd = Get-PriceFromCoinGecko -Asset $asset
        if ($null -eq $priceUsd) {
            $priceUsd = Read-Decimal "Auto failed or not available. Enter price in USD (optional)"
        }
    } else {
        $priceUsd = Read-Decimal "Price in USD (per unit, optional)"
    }

    $amount = Read-Decimal "Token amount (eg 0.1, 5, etc.)"

    $totalUsd = $null
    if ($amount -ne $null -and $priceUsd -ne $null) {
        $totalUsd = [decimal]$amount * [decimal]$priceUsd
    }

    $tags = Read-Host "Memo or tags (reason, strategy, notes, optional)"

    $row = @{
        timestamp = (Get-Date).ToString("s")
        action    = $action
        asset     = $asset
        amount    = $amount
        priceUsd  = $priceUsd
        totalUsd  = $totalUsd
        exchange  = $exchange
        location  = $location
        tags      = $tags
    }

    Append-CsvRow -Name "crypto" -Row $row
    Write-Host "Crypto entry saved." -ForegroundColor Green
}

function Log-Creative {
    Write-Host ""
    Write-Host "=== Creative Log ===" -ForegroundColor Cyan
    Write-Host "Use this for podcast ideas, bits, beats, projects, etc."
    Write-Host ""

    $kind   = Read-Host "Type (eg idea, bit, song, project)"
    if ([string]::IsNullOrWhiteSpace($kind)) { $kind = "idea" }

    $title  = Read-Host "Title or short label"
    $detail = Read-Host "Details (optional)"

    $row = @{
        timestamp = (Get-Date).ToString("s")
        kind      = $kind
        title     = $title
        detail    = $detail
    }

    Append-CsvRow -Name "creative" -Row $row
    Write-Host "Creative entry saved." -ForegroundColor Green
}

function Show-Dashboard {
    Write-Host ""
    Write-Host "=== Dashboard (Last 7 Days) ===" -ForegroundColor Cyan
    $since = (Get-Date).AddDays(-7)

    # Money
    $money = Get-Log -Name "money" | Where-Object {
        $ts = $_.timestamp
        $dt = $null
        if ([datetime]::TryParse($ts, [ref]$dt)) {
            return $dt -ge $since
        } else {
            return $false
        }
    }

    $income = 0.0
    $expense = 0.0
    foreach ($m in $money) {
        $amt = 0.0
        [decimal]::TryParse($m.amount, [ref]$amt) | Out-Null
        if ($m.type -eq "income") {
            $income += $amt
        } elseif ($m.type -eq "expense") {
            $expense += $amt
        }
    }

    Write-Host ""
    Write-Host "Money:" -ForegroundColor White
    Write-Host ("  Income : ${0:N2}" -f $income)
    Write-Host ("  Expense: ${0:N2}" -f $expense)
    Write-Host ("  Net    : ${0:N2}" -f ($income - $expense))

    # Habits
    $habits = Get-Log -Name "habits" | Where-Object {
        $ts = $_.timestamp
        $dt = $null
        if ([datetime]::TryParse($ts, [ref]$dt)) {
            return $dt -ge $since
        } else {
            return $false
        }
    }

    $moodSum = 0
    $moodCount = 0
    foreach ($h in $habits) {
        $moodVal = 0
        if ([int]::TryParse($h.mood, [ref]$moodVal) -and $moodVal -gt 0) {
            $moodSum += $moodVal
            $moodCount++
        }
    }

    Write-Host ""
    Write-Host "Habits / Workouts:" -ForegroundColor White
    Write-Host ("  Entries : {0}" -f $habits.Count)
    if ($moodCount -gt 0) {
        $avgMood = [double]$moodSum / [double]$moodCount
        Write-Host ("  Avg mood: {0:N1} / 10" -f $avgMood)
    } else {
        Write-Host "  Avg mood: n/a"
    }

    # Crypto
    $crypto = Get-Log -Name "crypto" | Where-Object {
        $ts = $_.timestamp
        $dt = $null
        if ([datetime]::TryParse($ts, [ref]$dt)) {
            return $dt -ge $since
        } else {
            return $false
        }
    }

    $totalUsd = 0.0
    foreach ($c in $crypto) {
        $val = 0.0
        [decimal]::TryParse($c.totalUsd, [ref]$val) | Out-Null
        $totalUsd += $val
    }

    Write-Host ""
    Write-Host "Crypto:" -ForegroundColor White
    Write-Host ("  Entries   : {0}" -f $crypto.Count)
    Write-Host ("  Total USD : ${0:N2}" -f $totalUsd)

    $recentCrypto = $crypto | Sort-Object -Property timestamp -Descending | Select-Object -First 3
    if ($recentCrypto.Count -gt 0) {
        Write-Host "  Recent entries:"
        foreach ($c in $recentCrypto) {
            Write-Host ("    {0} {1} {2} @ {3}" -f $c.action, $c.amount, $c.asset, $c.priceUsd)
        }
    }

    # Creative
    $creative = Get-Log -Name "creative" | Where-Object {
        $ts = $_.timestamp
        $dt = $null
        if ([datetime]::TryParse($ts, [ref]$dt)) {
            return $dt -ge $since
        } else {
            return $false
        }
    }

    Write-Host ""
    Write-Host "Creative:" -ForegroundColor White
    Write-Host ("  Entries : {0}" -f $creative.Count)

    Write-Host ""
    Write-Host ("Log root: {0}" -f $AppRoot) -ForegroundColor DarkGray
}

function Export-CSV-All {
    Write-Host ""
    Write-Host "=== Export Logs to CSV ===" -ForegroundColor Cyan

    $names = @("money", "habits", "crypto", "creative")
    foreach ($name in $names) {
        $data = Get-Log -Name $name
        if ($data.Count -gt 0) {
            $dest = Join-Path $ExportDir ("{0}.csv" -f $name)
            $data | Export-Csv -Path $dest -NoTypeInformation -Encoding UTF8
            Write-Host ("Exported {0} entries to {1}" -f $name, $dest) -ForegroundColor Green
        } else {
            Write-Host ("No entries to export for {0}." -f $name) -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    Write-Host ("Exports folder: {0}" -f $ExportDir) -ForegroundColor DarkGray
}

function Backup-Logs {
    Write-Host ""
    Write-Host "=== Backup Logs ===" -ForegroundColor Cyan

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $dest = Join-Path $BackupRoot $timestamp
    New-Item -ItemType Directory -Path $dest | Out-Null

    $csvFiles = Get-ChildItem -Path $DataDir -Filter "*.csv" -File -ErrorAction SilentlyContinue
    if ($csvFiles.Count -eq 0) {
        Write-Host "No CSV logs found to back up." -ForegroundColor DarkGray
    } else {
        foreach ($f in $csvFiles) {
            Copy-Item -Path $f.FullName -Destination $dest
        }
        Write-Host ("Backed up {0} file(s) to {1}" -f $csvFiles.Count, $dest) -ForegroundColor Green
    }
}

function Show-Banner {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "        TYLER OS LOG APP — 4.1"
    Write-Host "========================================"
    Write-Host ("Log root: {0}" -f $AppRoot)
    Write-Host ""
}

function Show-MainMenu {
    Write-Host ""
    Write-Host "1) Money Log"
    Write-Host "2) Habit / Workout Log"
    Write-Host "3) Crypto Log (Advanced)"
    Write-Host "4) Creative Log"
    Write-Host "5) Dashboard (7 days)"
    Write-Host "6) Export all to CSV"
    Write-Host "7) Backup all logs now"
    Write-Host "Q) Quit"
    Write-Host ""
}

Show-Banner

while ($true) {
    Show-MainMenu
    $choice = Read-Host "Choice"
    switch ($choice.ToUpper()) {
        "1" { Log-Money; Pause }
        "2" { Log-Habit; Pause }
        "3" { Log-Crypto; Pause }
        "4" { Log-Creative; Pause }
        "5" { Show-Dashboard; Pause }
        "6" { Export-CSV-All; Pause }
        "7" { Backup-Logs; Pause }
        "Q" { break }
        default {
            Write-Host "Invalid choice. Try again." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}
