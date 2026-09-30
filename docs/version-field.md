# Document version contract, revision 1

This contract is for independent readers of Grasshopper `.gh` and `.ghx` files written by GhTools 3.x. No GhTools library is required to implement it.

## Field and interpretation

The exact chunk path is `Root/Definition/ValueTable`. The exact, case-sensitive item name is `GhTools.Version`, with string type code `10`. The table is stored before the sibling `Root/Definition/DefinitionObjects` chunk. A similarly named item in another chunk is not this field.

The value consists of three nonempty ASCII decimal components separated by two dots. Leading zeroes are forbidden except for the single digit `0`. Signs, whitespace, prefixes, prerelease suffixes and build metadata are not accepted. Compare and validate text without converting the components into fixed-width integers. For example, `1.2.3` and `0.0.0` are valid; `01.2.3`, `v1.2.3` and `1.2.3+4` are invalid.

| Result | Meaning |
|---|---|
| valid | Exactly one matching string item contains a canonical version. |
| missing | No matching string item was found before the object section. |
| invalid | One matching string item exists but its text is not canonical. |
| duplicate | More than one matching string item exists; do not choose the first or last. |
| malformed | Required header bytes/XML cannot be read safely. |

Resource-limit failures must be explicit errors, never `missing`. Declare reader limits for header size, string size, nesting and buffered reads. The supplied native acceptance reader limits header consumption to 1 MiB, strings to 64 KiB and nesting to 32 levels.

## Binary framing

The `.gh` byte stream uses raw DEFLATE, without a zlib or gzip wrapper. After inflation, each chunk consists of its name string, signed 32-bit index, signed 32-bit item count, and signed 32-bit child-chunk count, followed by items and then child chunks. Integers are little-endian. A string uses a .NET-style 7-bit encoded unsigned byte length followed by UTF-8 bytes. Reject invalid or excessive lengths before allocating.

Each item consists of its name string, signed 32-bit index, signed 32-bit type code, and typed value. The version value is another length-prefixed UTF-8 string. Unknown item types must fail safely because their byte lengths cannot be guessed.

Known fixed-width item payload sizes used by the reader:

| Type codes | Bytes |
|---|---:|
| 1, 2 | 1 |
| 3, 5, 36 | 4 |
| 4, 6, 8, 30, 31, 32, 33 | 8 |
| 80 | 12 |
| 7, 9, 34, 35, 50, 60 | 16 |
| 51 | 24 |
| 52, 61 | 32 |
| 70, 71 | 48 |
| 72 | 72 |

Type 10 is a string. Types 20 and 37 contain a signed 32-bit byte count and that many bytes. Type 21 contains a signed 32-bit element count followed by that many 8-byte values. Reject negative counts, overflow and short reads. The plane-before-version vector exercises type 72.

Traverse the exact hierarchy. Stop when the direct `DefinitionObjects` child of `Root/Definition` begins, before consuming its items or children. Do not stop at an identically named chunk elsewhere. Record compressed input pulled and inflated bytes consumed separately: buffering may pull more compressed bytes than the parser consumes.

## XML representation

The XML document root is `<Archive name="Root">`. Child chunks appear in `<chunks>` elements and items in `<items>` elements. The field is a direct item of the direct `ValueTable` child of `Definition`:

```xml
<Archive name="Root"><chunks><chunk name="Definition"><chunks>
  <chunk name="ValueTable"><items>
    <item name="GhTools.Version" type_name="gh_string" type_code="10">1.2.3</item>
  </items></chunk>
  <chunk name="DefinitionObjects" />
</chunks></chunk></chunks></Archive>
```

Use a forward XML parser with DTD/external-entity processing disabled. Match the exact chunk hierarchy, direct item placement, key and type code. Decode XML text/CDATA normally. Stop at the direct object-section element; do not load the complete document into a DOM.

## Header-only versus whole-file checks

A complete header can be valid even when the later object section is truncated or invalid. `valid` therefore does not certify the full archive. The header-only reader never reads Panels and cannot detect header/Panel disagreement. The mismatch vectors correctly return `valid` for header-only reads; full GhTools verification rejects disagreement.

Named GhTools version reads prefer a valid header, fall back to an older version Panel when the header is absent, and reject disagreements. Legacy positional reads continue to read the Panel. Writers synchronize both values. Upgrade all writers of the same files together; a 2.x writer can leave an existing header stale.

## Fixtures and changes to the contract

Use [the hashed manifest](../fixtures/header/manifest.json). Most cases are minimal parser vectors, not complete editable Grasshopper definitions. Do not require whole-file verification to pass for those minimal vectors. Saved-document evidence is identified separately in [the acceptance report](acceptance-evidence.md).

Revision 1 does not support build metadata or additional identity fields. Any future extension must explicitly version its contract and define older-reader behavior. Consumers must not infer new syntax or alternate storage locations.
