# GhVersionManager and GhTools

Use these .NET 8 command-line tools to read, check, and update Grasshopper `.gh` and `.ghx` files in automated workflows.

- **GhVersionManager** keeps the established version-panel command and existing pipeline usage.
- **GhTools** adds file verification, size inspection, data cleanup, object editing, and before/after checks.

## Install

For an existing version-management pipeline:

```powershell
dotnet tool install --global GhVersionManager --version 2.0.2
ghversionmanager path\to\definition.gh
ghversionmanager path\to\definition.gh -v 1.2.3
```

For the expanded command set:

```powershell
dotnet tool install --global GhTools --version 2.0.2
ghtools verify path\to\definition.gh
```

The existing `ghversionmanager` command and exit-code behavior remain available in the compatibility package. `ghtools version` provides the same version-panel operation in GhTools.

## Features

| Command | Purpose |
|---|---|
| `ghversionmanager file.gh` | Read the first panel nicknamed `version`. |
| `ghversionmanager file.gh -v 1.2.3` | Set that panel, creating it if needed. |
| `ghtools verify file.gh` | Check known archive counters, indices, wires, groups, and references. |
| `ghtools weigh file.gh --top 10` | Show which objects contribute most to file size. |
| `ghtools strip file.gh --nick strip` | Remove internalized parameter data selected by nickname. |
| `ghtools delete file.gh --nick delete` | Remove selected objects and their associated references. |
| `ghtools clone file.gh --guid G` | Copy an object with fresh identifiers. |
| `ghtools connect` / `disconnect` | Add or remove a wire between parameters. |
| `ghtools set` | Change a nickname, panel text, or supported persistent value. |
| `ghtools replace` | Replace an object and transfer its connections by parameter position. |
| `ghtools ghx input.gh output.ghx` | Export the XML representation for inspection or comparison. |
| `ghtools attest before.gh after.gh -r report.json` | Check an operation's before/after result. |

Run `ghtools <command> --help` for the complete options. Editing commands write a separate output file by default. `--in-place` overwrites the input and keeps a `.bak`; `--dry-run` reports what would change without writing it.

## Worked GitHub Actions examples

The workflows in [`.github/workflows`](.github/workflows) are complete examples that can be copied into another repository. Each one shows the install step, file selection, command invocation, exit-code handling, and resulting commit or report.

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

Version 2.0.2 supports archive operations on Windows and Linux. Linux runners need `libgdiplus`; the included workflows install it before using either tool. The examples use `ubuntu-latest`, while the same commands remain valid on Windows.

## Exit codes

| Code | Meaning |
|---:|---|
| `0` | Command completed successfully. |
| `1` | Processing failed or the result was invalid. |
| `2` | Usage error, missing file, or no version panel/value. |
| `3` | An edit selector matched nothing or a write failed. |

## Current release

Version `2.0.2`:

- keeps the original version-panel pipeline command;
- adds verification, file-size inspection, conversion, cleanup, and object-editing commands;
- supports Windows and Linux pipelines.

## Feedback and license

Report bugs or feature requests through [GitHub Issues](https://github.com/timsdesigns/GhVersionManager/issues).

MIT License. See [LICENSE](LICENSE).
