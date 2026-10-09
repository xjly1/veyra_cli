# Veyra CLI

**A lightweight command-line utility built with Rust.**

Veyra CLI is a command-line tool designed to simplify common development workflows through practical commands and structured output.

The project prioritizes simplicity, reliability, maintainability, and useful functionality without unnecessary complexity.

> **Project Status:** Veyra CLI is currently in its initial release, `v1.0.0`. The project is under active development, and its functionality may evolve in future releases.

**Repository:** [github.com/xjly1/veyra_cli](https://github.com/xjly1/veyra_cli)

---

## Table of Contents

* [Overview](#overview)
* [Project Goals](#project-goals)
* [Getting Started](#getting-started)
* [Available Commands](#available-commands)
* [Project Structure](#project-structure)
* [How Veyra Works](#how-veyra-works)
* [Current Limitations](#current-limitations)
* [Development](#development)
* [License](#license)

---

## Overview

Veyra CLI is a Rust-based command-line utility that provides a consistent interface for executing development-oriented tasks.

The project follows a simple principle: every command should serve a practical purpose and provide meaningful value.

Rather than introducing unnecessary features, Veyra focuses on commands that are easy to understand, predictable to use, and maintainable over time.

Development is incremental, with future releases intended to improve existing functionality and introduce new capabilities where there is a clear need.

## Project Goals

Veyra follows these core principles:

* **Simplicity:** Keep commands and their usage straightforward.
* **Practicality:** Introduce features that solve real problems.
* **Reliability:** Make command behavior predictable and improve error handling.
* **Efficiency:** Reduce unnecessary steps in common workflows.
* **Maintainability:** Keep the codebase organized and easy to extend.
* **Controlled Growth:** Add functionality based on its practical value rather than feature count.

New commands should provide a clear benefit, such as simplifying a workflow, preventing mistakes, improving visibility, or reducing unnecessary work.

## Getting Started

### Installation

For installation instructions, see [`HowToInstall.md`](HowToInstall.md).

The guide explains how to download and run the PowerShell installer, install Veyra CLI, configure the user `PATH`, and verify the installation.

### Running Veyra

The general command syntax is:

```text
veyra <command> [options]
```

Examples:

```powershell
veyra help
veyra version
veyra tree
```

The official command name is `veyra`. The executable is named `veyra.exe`.

## Available Commands

Veyra CLI `v1.0.0` provides the following commands and options.

### 1. Help

Displays information about the available Veyra commands.

```powershell
veyra help
```

Command descriptions are maintained as Markdown files in `src/help/` and embedded into the executable during compilation.

### 2. Version

Displays the current Veyra version.

```powershell
veyra version
```

Version information can also be displayed using either of these flags:

```powershell
veyra -v
veyra --version
```

Both flags display the version information.

### 3. Tree

Displays a structured representation of the current working directory.

The Tree command supports directory-only output, full filesystem structure, and saving the structure to a Markdown file.

#### Default mode

```powershell
veyra tree
```

Displays directories only. Files are excluded from the output.

Example:

```text
.
├── src/
├── tests/
└── docs/
```

#### Full structure: `-f`

```powershell
veyra tree -f
```

Displays both directories and files.

Example:

```text
.
├── src/
│   ├── main.rs
│   └── parser.rs
├── Cargo.toml
└── README.md
```

#### Save structure: `-s`

```powershell
veyra tree -s
```

Saves the directory structure to a Markdown file named:

```text
structure_by_veyra.md
```

The file is created in the current working directory. This mode follows the default Tree behavior and includes directories only.

Instead of printing the complete structure to the terminal, Veyra writes it to the file and displays a confirmation message.

#### Combine `-f` and `-s`

```powershell
veyra tree -f -s
```

Or:

```powershell
veyra tree -s -f
```

Both forms produce the same result.

The command includes directories and files, then saves the complete structure to `structure_by_veyra.md` in the current working directory.

The order of these two options does not change the intended behavior.

### Tree Command Summary

| Command            | Behavior                                      |
| ------------------ | --------------------------------------------- |
| `veyra tree`       | Display directories only in the terminal      |
| `veyra tree -f`    | Display directories and files in the terminal |
| `veyra tree -s`    | Save the directory-only structure to Markdown |
| `veyra tree -f -s` | Save directories and files to Markdown        |
| `veyra tree -s -f` | Same behavior as `-f -s`                      |

#### Filtering

The Tree command supports filtering based on rules read from a `.gitignore` file in the current working directory.

This helps exclude matching files and directories from the displayed or saved structure. The filtering behavior is implemented by Veyra and should not be assumed to support every feature of Git's `.gitignore` specification.

## Project Structure

The source code is organized into separate modules so that command implementations, argument parsing, execution, and documentation remain distinct.

```text
veyra_cli/
├── src/
│   ├── commands/
│   │   ├── mod.rs
│   │   ├── help.rs
│   │   ├── tree.rs
│   │   └── version.rs
│   ├── help/
│   │   ├── help.md
│   │   ├── tree.md
│   │   └── version.md
│   ├── executor.rs
│   ├── main.rs
│   └── parser.rs
├── Cargo.toml
├── Cargo.lock
├── LICENSE
├── README.md
├── HowToInstall.md
├── install.ps1
└── .gitignore
```

### `src/`

Contains the application's Rust source code and internal modules.

### `src/commands/`

Contains the implementations of individual commands.

* `mod.rs` — organizes the command modules.
* `help.rs` — implements the Help command and reads embedded help assets.
* `tree.rs` — implements filesystem traversal, filtering, and structure output.
* `version.rs` — implements version-related functionality.

Separating commands into individual modules helps keep the codebase organized as the project evolves.

### `src/help/`

Contains the Markdown documentation associated with Veyra's commands.

* `help.md` — documentation for the Help command.
* `tree.md` — documentation for the Tree command and its options.
* `version.md` — documentation for version information.

The `rust-embed` crate embeds these assets into the executable during compilation. Consequently, users do not need a separate `help/` directory beside the executable at runtime.

When adding another Markdown help file to this directory, the embedded assets are updated the next time the project is rebuilt.

### `src/executor.rs`

Responsible for dispatching parsed commands to their corresponding implementations.

It connects command interpretation with command execution.

### `src/main.rs`

The application's entry point. It initializes the program and starts the command-processing workflow.

### `src/parser.rs`

Responsible for interpreting command-line arguments and identifying commands and options.

The parsed input is passed to the execution layer.

### `Cargo.toml`

Defines the Rust package configuration, version, dependencies, and build-related metadata.

### `Cargo.lock`

Records the resolved dependency versions used by the project.

### `LICENSE`

Contains the project's license terms. Veyra CLI is distributed under GNU GPL version 3 only (`GPL-3.0-only`).

### `README.md`

Provides the project's introduction, command reference, architecture overview, development instructions, and licensing information. Installation instructions are maintained separately in `HowToInstall.md`.

### `HowToInstall.md`

Provides step-by-step instructions for downloading and running the installer, installing Veyra CLI, and verifying the installation.

### `install.ps1`

The PowerShell installation script. It is intended to download the published `veyra.exe`, place it in `C:\Veyra`, and add that directory to the user's `PATH`.

The installer depends on a published GitHub Release containing the executable at the download URL configured in the script.

### `.gitignore`

Specifies files and directories that Git should exclude from version control, such as generated build artifacts.

## How Veyra Works

Veyra uses a modular command-processing workflow.

At a high level, the workflow consists of the following stages:

1. **Input:** The user supplies a command and optional arguments.
2. **Parsing:** The parser interprets the command-line arguments.
3. **Dispatch:** The executor determines which command implementation should run.
4. **Execution:** The selected command performs its operation.
5. **Output:** The result is displayed in the terminal or saved to a file, depending on the command and options.

Conceptually:

```text
User Input
    |
    v
main.rs
    |
    v
parser.rs
    |
    v
executor.rs
    |
    v
commands/
    |
    v
Terminal or File Output
```

The Tree command, for example, traverses the current working directory, applies its supported filtering rules, builds the requested structure, and either prints it or saves it to a Markdown file.

The Help command reads the Markdown assets embedded into the executable and extracts command names and descriptions for its output.

This modular design provides a foundation for improving existing commands and introducing additional functionality in future releases.

## Current Limitations

Veyra CLI is an early-stage project. Version `v1.0.0` focuses on a limited set of core commands rather than a broad feature set.

Error handling, argument validation, and command-line feedback may be refined in subsequent releases.

The Tree command's filtering implementation supports a subset of `.gitignore`-style behavior and is not intended to be a complete replacement for Git's ignore-pattern engine.

Future versions may improve existing functionality, introduce additional commands, and refine the user experience.

## Development

Veyra CLI is written in Rust.

### Prerequisites

To build Veyra from source on Windows, install:

* Rust and Cargo.
* The appropriate C++ build tools and Windows SDK for the selected Rust toolchain.

### Clone the repository

```powershell
git clone https://github.com/xjly1/veyra_cli.git
cd veyra_cli
```

### Build the release executable

```powershell
cargo build --release
```

The release executable is generated in:

```text
target/release/veyra.exe
```

The executable name is defined by the package configuration in `Cargo.toml`.

### Run locally

```powershell
.\target\release\veyra.exe help
.\target\release\veyra.exe --version
.\target\release\veyra.exe tree
```

### Adding help documentation

To add a Markdown help document:

1. Create a `.md` file in `src/help/`.
2. Use a first-level Markdown heading (`#`) for the command name.
3. Put the command description on the following non-empty line.
4. Rebuild the project with `cargo build --release`.

The embedded help assets are updated at compilation time. No separate runtime documentation directory is required.

## License

Veyra CLI is licensed under the **GNU General Public License v3.0 only (`GPL-3.0-only`)**. See the [`LICENSE`](https://github.com/xjly1/veyra_cli/blob/main/LICENSE) file for the complete license text.

You may use, study, copy, modify, and redistribute this project in accordance with the license terms.

If you redistribute Veyra CLI or a modified version, you must comply with the applicable GPL-3.0 requirements. These include retaining relevant copyright and license notices, providing the corresponding source code under the required conditions, and licensing covered derivative works under GPL-3.0-only.

You may use or distribute the project commercially, provided you comply with the license.

Please preserve the original copyright and license notices when reusing the project, and clearly identify your modifications where required by the GPL.

---

**Veyra CLI — Built with Rust. Designed for practical workflows.**
