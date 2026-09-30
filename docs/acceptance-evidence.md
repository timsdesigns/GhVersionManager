# Acceptance evidence

The fixture manifest gives independent expected header-only results, byte counts and SHA-256 hashes. The native test adapter reads the manifest as its oracle; it does not call GhTools to decide the expected result. Both binary and XML cases are exercised.

The suite includes valid/missing/invalid/duplicate fields, header/Panel disagreement, case-varied Panels, wrong-location decoys, nested XML decoys, malformed input, truncation before and after the header, large object sections, and a plane item before the version. Header-only success after the header does not certify the unread remainder of the file.

Windows retained evidence confirms `1.2.3` survives a real Rhino/Grasshopper 8.30.26051.14001 GUI open/save for `.gh` and `.ghx`, and a separately hosted `.ghx` save. This is document-host serialization evidence, not merely an archive-library round trip. A Windows document-host edit/save test also changed a non-version Panel nickname and preserved both that edit and the header in both formats. See [the sanitized receipt](save-evidence.json) and the `saved-after-edit` fixtures.

CLI regression coverage includes root and required-option help, explicit verification JSON, missing-file and usage exit codes, dry-run writes, separate-output writes, ambiguous displaced Panels, and repeated normalization/version-write composition. Normalization still leaves a component variant with no selected Version input without a canonical version Panel.

The supplied native reader required updates to its field location/default, canonical version validation and duplicate handling. Binary and XML acceptance runs use an isolated adaptation of that consumer. This does not certify deployed Windows property handlers, a registered macOS importer, signing or installation. Those platform adapters require their own integration checks.

macOS CLI installation and archive smoke passed release CI with .NET and native image support. Full macOS Rhino/Grasshopper GUI acceptance still requires an owner-run checklist. A successful CLI run is not evidence of Finder display behavior.


The current [native result table](native-reader-results.json) records 29/29 passing vectors. The producer suite contains 73 passing test cases, including the retained vector-manifest tests. The plane fixture exposed and now guards a corrected binary skip-width defect.

