
$ErrorActionPreference = "Stop"

$Repo = "xjly1/veyra_cli"
$InstallDir = "C:\Veyra"
$InstallExe = Join-Path $InstallDir "veyra.exe"
$ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
$TempDir = Join-Path $env:TEMP ("VeyraInstall-" + [guid]::NewGuid().ToString("N"))
$BackupDir = "$InstallDir.backup-" + [guid]::NewGuid().ToString("N")

function Get-ReleaseInfo {
    Write-Host "Checking the latest official Veyra release..."

    $release = Invoke-RestMethod -Uri $ApiUrl -Headers @{
        Accept = "application/vnd.github+json"
        "User-Agent" = "Veyra-CLI-Installer"
    }

    if ($release.draft -or $release.prerelease) {
        throw "The latest release is not a stable release."
    }

    if ($release.tag_name -notmatch '^(?i:Veyra-Cli_v)(\d+\.\d+\.\d+)$') {
        throw "Invalid release tag: $($release.tag_name)"
    }

    $versionText = $Matches[1]

    $asset = @(
        $release.assets | Where-Object {
            $_.name -eq "veyra.exe"
        }
    ) | Select-Object -First 1

    if (-not $asset) {
        throw "The official release does not contain veyra.exe."
    }

    if ($asset.browser_download_url -notmatch '^https://github\.com/') {
        throw "The release download URL is not trusted."
    }

    if ($asset.digest -notmatch '^sha256:[0-9a-fA-F]{64}$') {
        throw "A valid SHA-256 digest is missing. Download rejected."
    }

    return [pscustomobject]@{
        Version = [version]$versionText
        Url = $asset.browser_download_url
        Sha256 = ($asset.digest -replace '^sha256:', '').ToLowerInvariant()
    }
}

function Get-CommandPath {
    $command = Get-Command veyra -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($command) {
        return $command.Source
    }

    return $null
}

function Get-InstalledVersion {
    param([string]$ExePath)

    if (-not (Test-Path -LiteralPath $ExePath -PathType Leaf)) {
        return $null
    }

    try {
        $output = @(& $ExePath -v 2>&1)
        $exitCode = $LASTEXITCODE

        if ($exitCode -ne 0 -or $output.Count -ne 1) {
            return $null
        }

        $text = "$($output[0])".Trim()

        if ($text -notmatch '^\d+\.\d+\.\d+$') {
            return $null
        }

        return [version]$text
    }
    catch {
        return $null
    }
}

function Add-VeyraToPath {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    $userEntries = @(
        $userPath -split ';' | Where-Object {
            $_ -and $_.Trim().Trim('"').TrimEnd('\') -ine $InstallDir.TrimEnd('\')
        }
    )

    $newUserPath = (@($userEntries) + $InstallDir) -join ';'

    [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")

    $processEntries = @(
        $env:Path -split ';' | Where-Object {
            $_ -and $_.Trim().Trim('"').TrimEnd('\') -ine $InstallDir.TrimEnd('\')
        }
    )

    $env:Path = (@($InstallDir) + $processEntries) -join ';'
}

function Test-Veyra {
    param([string]$ExpectedVersion)

    $resolved = Get-CommandPath

    if (-not $resolved -or
        -not [string]::Equals(
            [IO.Path]::GetFullPath($resolved),
            [IO.Path]::GetFullPath($InstallExe),
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw "The veyra command does not resolve to $InstallExe."
    }

    $versionOutput = @(& veyra -v 2>&1)
    $versionExit = $LASTEXITCODE

    if ($versionExit -ne 0 -or
        $versionOutput.Count -ne 1 -or
        "$($versionOutput[0])".Trim() -ne $ExpectedVersion) {
        throw "The veyra -v verification failed."
    }

    $helpOutput = @(& veyra help 2>&1)
    $helpExit = $LASTEXITCODE

    if ($helpExit -ne 0 -or $helpOutput.Count -eq 0) {
        throw "The veyra help verification failed."
    }
}

function Install-VerifiedRelease {
    param($Release)

    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

    $downloadPath = Join-Path $TempDir "veyra.exe"

    Write-Host "Downloading Veyra CLI v$($Release.Version)..."

    Invoke-WebRequest -Uri $Release.Url -OutFile $downloadPath -UseBasicParsing

    $actualHash = (Get-FileHash -LiteralPath $downloadPath -Algorithm SHA256).Hash.ToLowerInvariant()

    if ($actualHash -ne $Release.Sha256) {
        throw "SHA-256 verification failed. The downloaded file was rejected."
    }

    $downloadedVersion = Get-InstalledVersion -ExePath $downloadPath

    if ($downloadedVersion -ne $Release.Version) {
        throw "The downloaded executable version does not match the release."
    }

    $hadOldInstall = Test-Path -LiteralPath $InstallDir

    if ($hadOldInstall) {
        Rename-Item -LiteralPath $InstallDir -NewName (Split-Path $BackupDir -Leaf)
    }

    try {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Copy-Item -LiteralPath $downloadPath -Destination $InstallExe

        Add-VeyraToPath
        Test-Veyra -ExpectedVersion "$($Release.Version)"

        if (Test-Path -LiteralPath $BackupDir) {
            Remove-Item -LiteralPath $BackupDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        if (Test-Path -LiteralPath $InstallDir) {
            Remove-Item -LiteralPath $InstallDir -Recurse -Force
        }

        if ($hadOldInstall -and (Test-Path -LiteralPath $BackupDir)) {
            Rename-Item -LiteralPath $BackupDir -NewName (Split-Path $InstallDir -Leaf)
        }

        throw
    }
}

try {
    Write-Host "Veyra CLI Installer" -ForegroundColor Cyan

    $release = Get-ReleaseInfo
    $latestVersion = $release.Version

    $resolvedCommand = Get-CommandPath
    $isOfficialPath = $false

    if ($resolvedCommand) {
        $isOfficialPath = [string]::Equals(
            [IO.Path]::GetFullPath($resolvedCommand),
            [IO.Path]::GetFullPath($InstallExe),
            [StringComparison]::OrdinalIgnoreCase
        )
    }

    $installedVersion = $null

    if ($isOfficialPath) {
        $installedVersion = Get-InstalledVersion -ExePath $InstallExe
    }

    if ($isOfficialPath -and $installedVersion -eq $latestVersion) {
        try {
            Add-VeyraToPath
            Test-Veyra -ExpectedVersion "$latestVersion"

            Write-Host "Veyra CLI v$latestVersion is already up to date." -ForegroundColor Green
        }
        catch {
            Write-Host "The current installation failed verification. Repairing..."
            Install-VerifiedRelease -Release $release
            Write-Host "Veyra CLI v$latestVersion repaired successfully." -ForegroundColor Green
        }
    }
    elseif ($isOfficialPath -and $installedVersion -and $installedVersion -gt $latestVersion) {
        Add-VeyraToPath
        Test-Veyra -ExpectedVersion "$installedVersion"

        Write-Host "The installed version ($installedVersion) is newer than the latest release ($latestVersion)." -ForegroundColor Yellow
    }
    else {
        if ($installedVersion) {
            Write-Host "Updating Veyra CLI from $installedVersion to $latestVersion..."
        }
        else {
            Write-Host "Veyra CLI is missing, invalid, or not correctly available through PATH. Installing..."
        }

        Install-VerifiedRelease -Release $release

        Write-Host "Veyra CLI v$latestVersion installed successfully!" -ForegroundColor Green
    }
}
catch {
    Write-Host ""
    Write-Host "Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    if (Test-Path -LiteralPath $TempDir) {
        Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}