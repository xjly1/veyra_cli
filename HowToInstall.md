# How to Install Veyra CLI

This guide explains how to install Veyra CLI on Windows using the provided PowerShell installer.

## Requirements

* Windows
* PowerShell
* An internet connection

Rust and Cargo are not required to install or run a published Veyra release.

## Step 1: Download the Installer

Download `install.ps1` from the [Veyra CLI GitHub repository](https://github.com/xjly1/veyra_cli).

Save the file to a convenient location, such as your Downloads folder.

## Step 2: Run the Installer

Open PowerShell and navigate to the directory where you saved `install.ps1`.

For example:

```powershell
cd "$HOME\Downloads"
```

Run the installer:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installer downloads `veyra.exe`, places it in `C:\Veyra`, and adds `C:\Veyra` to your user `PATH`.

Administrator privileges are not required.

## Step 3: Verify the Installation

After the installer finishes, close the current terminal and open a new PowerShell or Command Prompt window.

Run:

```powershell
where.exe veyra
veyra -v
```

The executable path should be:

```text
C:\Veyra\veyra.exe
```

Expected version output:

```text
Veyra v1.0.0
```

## Step 4: Use Veyra

Once installed, Veyra can be run from any working directory:

```powershell
veyra help
veyra version
veyra tree
```

## Troubleshooting

If the terminal reports that `veyra` is not recognized:

1. Close the current terminal and open a new one.
2. If the issue persists, completely close VS Code or your code editor and reopen it.
3. Check that `C:\Veyra\veyra.exe` exists.
4. Check that `C:\Veyra` is included in your user `PATH`.

To inspect your user `PATH`, run:

```powershell
[Environment]::GetEnvironmentVariable("Path", "User") -split ';'
```

To test the executable directly, run:

```powershell
& "C:\Veyra\veyra.exe" -v
```

If the direct command works but `veyra -v` does not, the issue is likely related to `PATH` or an outdated terminal environment.

## Notes

* The installer requires an available published release containing `veyra.exe`.
* If the latest release does not include the executable at the download URL configured in `install.ps1`, installation will fail.
* Always download the installer from the official [Veyra CLI repository](https://github.com/xjly1/veyra_cli).
