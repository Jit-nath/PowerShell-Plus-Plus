# --- PowerShell Profile ---

# Function: Activate Python virtual environment if available
function activate {
    $venvNames = @(".venv", "venv", "env")
    foreach ($name in $venvNames) {
        $path = Join-Path $PWD $name
        if (Test-Path "$path\Scripts\Activate.ps1") {
            & "$path\Scripts\Activate.ps1"
            Write-Host "✅ Activated virtual environment: $name" -ForegroundColor Green
            return
        }
    }
    Write-Host "⚠️ No virtual environment found in current directory." -ForegroundColor Yellow
}

# Go up n directories (default: 1)
function up {
    param([int]$n = 1)
    for ($i = 0; $i -lt $n; $i++) { Set-Location .. }
}

# Go to drive root
function up-root { Set-Location "\" }

# Common npm shortcuts
function run    { npm run dev }
function build  { npm run build }
function start  { npm start }

# Project generators
function next   { npx create-next-app@latest }
function vite   { npm create vite@latest }

# Quick navigation
function home       { Set-Location ~ }
function downloads  { Set-Location "C:\Users\jitde\Downloads" }
function desktop    { Set-Location "C:\Users\jitde\OneDrive\Desktop" }

# Edit profile
function profile { code $PROFILE }

# Edit any file
function edit {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    if (Test-Path $FilePath) {
        code $FilePath
    } else {
        Write-Host "❌ File not found. Use: edit ./path/to/file" -ForegroundColor Red
    }
}

# List all profile paths
function profiles {
    $map = [ordered]@{
        CurrentUserCurrentHost = $PROFILE
        CurrentUserAllHosts    = $PROFILE.CurrentUserAllHosts
        AllUsersCurrentHost    = $PROFILE.AllUsersCurrentHost
        AllUsersAllHosts       = $PROFILE.AllUsersAllHosts
    }
    foreach($k in $map.Keys){
        "{0,-22} : {1}" -f $k, $map[$k]
    }
}

# Robust reload: loads every existing profile and applies changes globally
function reload {
    $paths = @(
        $PROFILE,
        $PROFILE.CurrentUserAllHosts,
        $PROFILE.AllUsersCurrentHost,
        $PROFILE.AllUsersAllHosts
    ) | Select-Object -Unique | Where-Object { $_ -and (Test-Path $_) }

    if (-not $paths) {
        Write-Host "⚠️ No profile files found to reload." -ForegroundColor Yellow
        return
    }

    foreach ($p in $paths) {
        try {
            & $ExecutionContext.InvokeCommand.NewScriptBlock(". '$p'")
            Write-Host "🔄 Reloaded: $p" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed: $p -> $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Alias for quick reload
Set-Alias r reload

# --- Help Function ---
function help {
    Write-Host "`n📘 Help Box - Custom Commands`n" -ForegroundColor Cyan

    $commands = @(
        @{ Name = "activate";     Desc = "Activate Python virtual environment (venv/.venv/env) if present in current dir" },
        @{ Name = "up [n]";       Desc = "Go up n directories (default: 1)" },
        @{ Name = "up-root";      Desc = "Go to drive root" },
        @{ Name = "run";          Desc = "Run 'npm run dev'" },
        @{ Name = "build";        Desc = "Run 'npm run build'" },
        @{ Name = "start";        Desc = "Run 'npm start'" },
        @{ Name = "next";         Desc = "Scaffold a new Next.js project" },
        @{ Name = "vite";         Desc = "Scaffold a new Vite project" },
        @{ Name = "home";         Desc = "Go to home directory" },
        @{ Name = "downloads";    Desc = "Go to Downloads folder" },
        @{ Name = "desktop";      Desc = "Go to Desktop folder" },
        @{ Name = "profile";      Desc = "Open PowerShell profile in VSCode" },
        @{ Name = "edit <file>";  Desc = "Open a file in VSCode" },
        @{ Name = "profiles";     Desc = "List all PowerShell profile paths" },
        @{ Name = "reload (r)";   Desc = "Reload PowerShell profile(s)" }
    )

    $maxLen = ($commands | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum

    foreach ($cmd in $commands) {
        $padded = $cmd.Name.PadRight($maxLen)
        Write-Host (" " + $padded + " -> " + $cmd.Desc) -ForegroundColor Yellow
    }

    Write-Host "`n✅ Type 'reload' or 'r' to reload profile after edits`n" -ForegroundColor Green
}
