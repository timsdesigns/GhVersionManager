# GhVersionManager and GhTools

Use these .NET 8 command-line tools to read, check, and update Grasshopper `.gh` and `.ghx` files in automated workflows.

- **GhVersionManager** keeps the established version command and existing pipeline usage while synchronizing the document and version Panel on writes.
- **GhTools** adds document-version checks, Panel lookup and normalization, file verification, size inspection, data cleanup, object editing, and before/after checks.

## Install

Install the .NET 8 SDK to use `dotnet tool install`. These packages run on the .NET runtime; they are not self-contained executables. Rhino does not need to be installed to run the CLI. Full archive commands require runtime preparation through `ghtools bootstrap`, with network access on first setup if the required runtime files are not already available. Linux and macOS also need the native image support described below. Header-only reads skip that archive-runtime setup but still use .NET.

For an existing version-management pipeline:

```powershell
dotnet tool install --global GhVersionManager --version 3.1.1
ghversionmanager path\to\definition.gh
ghversionmanager path\to\definition.gh -v 1.2.3
```

For the expanded command set:

```powershell
dotnet tool install --global GhTools --version 3.1.1
ghtools verify path\to\definition.gh
```

The existing `ghversionmanager` command and exit-code behavior remain available in the compatibility package. Legacy reads still return the version Panel value; writes keep it synchronized with the document version. `ghtools version` reads the document version first, falls back to older version Panels, and reports disagreements.

## Moving from 2.x to 3.x

Version 3 introduces synchronized document and Panel versions. Upgrade every workflow that writes versions to the same files at the same time. After a version 3 write, a 2.x writer updates only the legacy Panel value and can leave the two values inconsistent. Version 3 reports that mismatch instead of silently selecting one.

To repair a mismatch, decide which version is correct and write it again with version 3:

```powershell
ghtools version path\to\definition.gh --set 1.2.3
```

Read-only 2.x consumers can continue reading the Panel value. `--header-only` returns not found for an older Panel-only file until a version 3 writer adds the document version. The unchanged 2.0.2 examples remain on the [`legacy/2.x`](https://github.com/timsdesigns/GhVersionManager/tree/legacy/2.x) branch.

## Features

| Command | Purpose |
|---|---|
| `ghversionmanager file.gh` | Read the first panel nicknamed `version`. |
| `ghversionmanager file.gh -v 1.2.3` | Set the version, creating the Panel if needed and synchronizing both stored values. |
| `ghtools version file.gh [--json]` | Read the document version with version-Panel fallback and report mismatches. |
| `ghtools version file.gh --header-only` | Read the early document version without loading the full definition. |
| `ghtools version file.gh --set 1.2.3` | Update the document version and version Panel together. |
| `ghtools panel file.gh --nick N [--all]` | Read stored Panel text and identify matching instances. |
| `ghtools normalize file.gh --type G --map Input=Nick` | Preview or apply Panel nicknames derived from their input wires. |
| `ghtools verify file.gh` | Check archive structure and version consistency. |
| `ghtools weigh file.gh --top 10` | Show which objects contribute most to file size. |
| `ghtools strip file.gh --nick strip` | Remove internalized parameter data selected by nickname. |
| `ghtools delete file.gh --nick delete` | Remove selected objects and their associated references. |
| `ghtools clone file.gh --guid G` | Copy an object with fresh identifiers. |
| `ghtools connect` / `disconnect` | Add or remove a wire between parameters. |
| `ghtools set` | Change a nickname, panel text, or supported persistent value. |
| `ghtools replace` | Replace an object while keeping compatible connections. |
| `ghtools ghx input.gh output.ghx` | Export the XML representation for inspection or comparison. |
| `ghtools attest before.gh after.gh -r report.json` | Check an operation's before/after result. |

Run `ghtools <command> --help` for the complete options. Object-editing commands write a separate output file by default; `--in-place` overwrites the input and keeps a `.bak`. Version writes update the input directly. `normalize` previews changes by default; use `--apply` to update the input or `--output` to choose a separate output file. A normalization with no changes writes nothing.

## Worked GitHub Actions examples

The workflows in [`.github/workflows`](.github/workflows) are complete examples that can be copied into another repository. Each one shows the install step, file selection, command invocation, exit-code handling, and resulting commit or report.

Copy [`.github/scripts/changed-files.ps1`](.github/scripts/changed-files.ps1) with the selected workflow. It handles initial pushes and multi-commit changes and stops the job if the comparison cannot be resolved. Keep the full-history checkout used by the examples.

The two write-back examples are alternatives. If versioning and cleanup must run on the same files for the same push, combine their command steps into one workflow so two jobs do not race to rewrite the same binary file.

### Auto-version: `gh-version.yaml`

This preserves the original GhVersionManager pipeline pattern:

- runs when a Grasshopper file is pushed;
- chooses a major, minor, or patch bump from the commit message;
- updates or creates the `version` panel;
- commits the changed file back to the branch.

Copy [`.github/workflows/gh-version.yaml`](.github/workflows/gh-version.yaml), then adjust the watched folder and version-bump words if your repository uses different conventions.

### Pull-request verification: `gh-verify.yaml`

This demonstrates the new read-only verification command:

- runs for pull requests that change Grasshopper files;
- checks each changed archive for known structural problems;
- fails the check when an error is found;
- uploads a JSON report for review.

Copy [`.github/workflows/gh-verify.yaml`](.github/workflows/gh-verify.yaml) and adjust the watched folder. Verification is an archive-structure check; it does not launch Grasshopper or prove that a definition solves successfully.

### Cleanup: `gh-slim.yaml`

This demonstrates two editing commands in a pipeline:

- parameters or components nicknamed `strip` lose their internalized data;
- objects nicknamed `delete` are removed;
- the changed file is verified and committed;
- JSON reports are uploaded for inspection.

Copy [`.github/workflows/gh-slim.yaml`](.github/workflows/gh-slim.yaml), then change `STRIP_NICK`, `DELETE_NICK`, the watched folder, or the trigger to match your policy. This example intentionally writes to the branch; use the verification example when a read-only check is preferred.

## Runner support

Version 3.1.1 supports archive operations on Windows and Linux. Linux runners need `libgdiplus`; the included workflows install it before using either tool. The examples use `ubuntu-latest`, while the same commands remain valid on Windows.

## Exit codes

Named `ghtools` commands use:

| Code | Meaning |
|---:|---|
| `0` | Command completed successfully. |
| `1` | The archive, operation, or verification failed. |
| `2` | Command usage was invalid. |
| `3` | The requested component, Panel, or object was not found. |
| `4` | A file or runtime input/output operation failed. |

Legacy `ghversionmanager` forms retain their established meanings: `0` success, `1` processing error, `2` missing version or usage error, and `3` write failure.

## Current release

Version `3.1.1`:

- fixes `ghtools --version` and `ghversionmanager --version` to print the installed tool version; archive and legacy command behavior is unchanged from 3.1.0;
- keeps the original version-panel pipeline command;
- synchronizes the document version and version Panel on writes;
- adds early document-version reads, mismatch checks, Panel lookup, and wire-based Panel normalization;
- includes verification, file-size inspection, conversion, cleanup, and object-editing commands;
- supports Windows and Linux pipelines.

## Feedback and license

Report bugs or feature requests through [GitHub Issues](https://github.com/timsdesigns/GhVersionManager/issues).

MIT License. See [LICENSE](LICENSE).

## Version-field consumers and guarded writes

The [version-field contract](docs/version-field.md), [hashed fixtures](fixtures/header/manifest.json) and [acceptance evidence](docs/acceptance-evidence.md) support independent readers.

`ghtools bootstrap` prepares the runtime for full archive operations. `verify --json` explicitly selects its existing JSON output. Root and subcommand help work without supplying required operands.

Version writes retain their direct-write default. `version file.gh --set 1.2.3 --dry-run` validates without writing; `--output new-file.gh` writes a separate file and refuses an existing destination. Both support `--json`.

A named version write reuses a unique `version__renamed` Panel when the canonical Panel is absent; multiple candidates fail without writing. Legacy positional writes are unchanged. Custom suffixes are not guessed. Automated component-specific pipelines should write only when normalization reports a selected Version input; a variant without that input stays unversioned.

## macOS scope

Installed CLI archive smoke is tested on macOS CI. Install .NET and `mono-libgdiplus` with Homebrew, then export `DYLD_LIBRARY_PATH="$(brew --prefix mono-libgdiplus)/lib"` and `DYLD_FALLBACK_LIBRARY_PATH="$DYLD_LIBRARY_PATH"` in the shell running the tool. This is CLI support for the tested operations, not certification of every macOS release, architecture, Rhino GUI workflow or Finder integration. Header-only reads do not need the image-library setup. Manual Rhino/Grasshopper checks remain separate.
