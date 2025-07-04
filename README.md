# GhVersionManager

**GhVersionManager** is a .NET 7 CLI tool and library for reading and writing version information in Grasshopper `.gh` and `.ghx` files. It is designed for automation, CI/CD, and team workflows, and is distributed as a NuGet package for easy integration.

 - [Jump to example](#github-actions-example-auto-versioning-grasshopper-files)

---

## Features

- **Read version** from the first panel with NickName `"version"` in a `.gh` or `.ghx` file.
- **Set or update version** in that panel, or create it if missing.
- **Interactive console mode** for manual workflows.
- **CLI mode** for scripting and automation, with clear exit codes for integration.
- **Reusable C# API** for .NET projects.
- **Single-file deployment**: all dependencies are embedded and loaded at runtime.
- **Windows support** (due to Grasshopper/GH_IO dependency).

---

## Usage

### As a CLI Tool

Install via NuGet (see [nuget.org/packages/GhVersionManager](https://www.nuget.org/packages/GhVersionManager)) or download from your CI/CD pipeline.

**Print the version from a `.gh` or `.ghx` file:**
`GhVersionManager.exe path\to\file.ghx GhVersionManager.exe path\to\file.gh`

**Set the version:**
`GhVersionManager.exe path\to\file.ghx -v 1.2.3 GhVersionManager.exe path\to\file.gh -v 1.2.3`


**Interactive mode:**  
Run without arguments to enter an interactive prompt.

### As a .NET Library

Reference the NuGet package in your project:
```csharp
using GhVersionManager;
string? version = GhVersionService.GetVersion("path/to/file.ghx");
bool ok = GhVersionService.SetVersion("path/to/file.ghx", "1.2.3");
```

---

## GitHub Actions Example: Auto-Versioning Grasshopper Files
You can automate version management for your Grasshopper files using GhVersionManager in a GitHub Actions workflow.

 - [![Example Steps on Youtube](https://img.youtube.com/vi/kIu7YrRCSZo/0.jpg)](https://www.youtube.com/watch?v=kIu7YrRCSZo)
    - [**Version Bump** - Increment (minor) version on file with version panel](https://www.youtube.com/watch?v=kIu7YrRCSZo)
    - [**Bug Fix** - Increment patch version](https://www.youtube.com/watch?v=kIu7YrRCSZo&t=135s)
    - [**Breaking Change** - Increment major version](https://www.youtube.com/watch?v=kIu7YrRCSZo&t=338s)
    - [**Adding Version** - Adding versioned (*0.1.0*) panel if non found](https://www.youtube.com/watch?v=kIu7YrRCSZo&t=455s)

### What the workflow does
•	Detects changes to .gh and .ghx files in your repo.
•	Determines version bump (major, minor, patch) from the commit message.
•	Updates or creates a version panel in each changed file.
•	Commits and pushes the updated files back to your repository.

### How to use
1.	Copy the [example workflow](./.github/workflows/gh-version.yaml) into .github/workflows/gh-version.yaml in your repository.
2.	Adjust the version of GhVersionManager in the workflow if needed.

### Version bump rules
•	MAJOR: If the commit message contains BREAKING or MAJOR
•	PATCH: If the commit message contains PATCH, FIX, or BUG
•	MINOR: For all other changes

### Notes
•	The workflow will create a version panel if one does not exist in a file.
•	The tool works on Windows runners due to Grasshopper dependencies.
•	You can adjust the workflow to fit your folder structure or versioning policy.

---

## Versioning & Changelog

**Current version:** `1.0.4-beta` (public beta)

### Changelog

- **1.0.4-beta**
  - Initial public beta release
  - CLI and interactive modes
  - Read/write version panel in `.gh` and `.ghx` files
  - Single-file deployment (no extra DLLs needed)
  - Windows support only

---

## Feedback & Issues

This is a **beta** release.  
Please report bugs, feature requests, or feedback via [GitHub Issues](https://github.com/timsdesigns/GhVersionManager/issues).

---

## License

MIT License. See [LICENSE.txt](LICENSE.txt) for details.

---

## Credits

- Inspired by scripts and advice from the Grasshopper community, especially [David Rutten](https://www.grasshopper3d.com/profile/DavidRutten) and [Andrew Heumann](https://www.grasshopper3d.com/profile/AndrewHeumann).
- Uses [GH_IO.dll](https://mcneel.github.io/grasshopper-api-docs/api/grasshopper/html/N_GH_IO.htm) for Grasshopper file access.
