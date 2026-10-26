# BPv7 Custody and Reporting

This repository contains three related individual Internet-Drafts for
Bundle Protocol Version 7 (BPv7), intended for discussion and possible
adoption by the IETF Delay/Disruption Tolerant Networking (DTN) Working
Group.

- Bundle Sequence Identification for BPv7
- Custody Transfer for BPv7
- Compressed Bundle Status Reporting for BPv7

The work is derived from the concepts and protocol mechanisms specified
in CCSDS 734.6-O-1, *Custody Transfer and Compressed Bundle Status
Reporting*.

## Internet-Drafts

All three documents are intended for publication on the IETF Standards
Track as Proposed Standards.

The authoritative sources are the kramdown-rfc Markdown files in
`drafts/`:

- `drafts/draft-flentge-dtn-bundle-sequence-identification-00.md`
- `drafts/draft-flentge-dtn-bpv7-custody-transfer-00.md`
- `drafts/draft-flentge-dtn-compressed-status-reporting-00.md`

RFCXML, text, and HTML files are generated artifacts produced from the
Markdown sources and should not be edited directly.

## Repository Structure

```text
.
├── README.md
├── .gitignore
├── traceability.md
├── issues.md
│
├── drafts/
│   ├── draft-flentge-dtn-bundle-sequence-identification-00.md
│   ├── draft-flentge-dtn-bpv7-custody-transfer-00.md
│   └── draft-flentge-dtn-compressed-status-reporting-00.md
│
├── tools/
│   └── build.ps1
│
└── build/
    ├── xml/
    ├── txt/
    └── html/
```

The `build/` directory contains generated output and is not intended for
version control.

## Authoring Workflow

Markdown files in `drafts/` are the authoritative authoring sources.

```text
Markdown (.md)
      │
      ▼
kramdown-rfc
      │
      ▼
xml2rfc preptool (RFCXML v3 normalization)
      │
      ▼
RFCXML (.xml)
      │
      ▼
xml2rfc
      │
      ├── TXT rendering
      └── HTML rendering
```

The build normalizes the kramdown-rfc output with xml2rfc's preptool
before rendering. This converts deprecated RFCXML v2 elements (such as
`<list>`) to RFCXML v3 equivalents and removes `<?line?>` processing
instructions, so the generated XML keeps the Datatracker's idnits3
check free of warnings.

Make all substantive, editorial, reference, and CDDL changes in the
Markdown files. Do not edit files under `build/` manually because the
next build will overwrite them.

To rebuild all drafts from the repository root:

```powershell
.\tools\build.ps1 -Clean
```

Generated files are written to:

```text
build/xml/
build/txt/
build/html/
```

The build may report an expected warning while the Bundle Sequence
Identification draft remains unpublished because the custody-transfer
and compressed-reporting drafts provide a complete inline reference for
that companion draft. After the companion draft is available through the
IETF Datatracker and BibXML library, the inline reference can be
replaced by the corresponding canned BibXML reference.

## Version Control

The Markdown files in `drafts/` are the authoritative document sources
and are maintained under version control.

The following files should be committed to Git:

```text
README.md
.gitignore
traceability.md
issues.md

drafts/
    draft-flentge-dtn-bundle-sequence-identification-00.md
    draft-flentge-dtn-bpv7-custody-transfer-00.md
    draft-flentge-dtn-compressed-status-reporting-00.md

tools/
    build.ps1
```

The following files are generated build artifacts and are normally not
committed:

```text
build/xml/*
build/txt/*
build/html/*
```

These artifacts can be regenerated at any time using:

```powershell
.\tools\build.ps1 -Clean
```

## Toolchain

The workflow requires:

- Ruby
- `kramdown-rfc`
- Python
- `xml2rfc`
- PowerShell for `tools/build.ps1`

Check the installed tools with:

```powershell
ruby --version
kramdown-rfc --version
python --version
xml2rfc --version
```

## Validation

A successful build confirms that all three Markdown documents can be
converted to RFCXML and rendered as text and HTML.

Before submission:

1. Review the generated text and HTML files.
2. Compare substantive changes against previous revisions.
3. Check the generated RFCXML using the current IETF author tools and
   Datatracker submission checks.
4. Review open items in `issues.md`.
5. Update `traceability.md` when requirements move between drafts or
   sections.

For a clean local validation run:

```powershell
.\tools\build.ps1 -Clean
```

## Source Material

The Internet-Drafts in this repository are derived from:

- CCSDS 734.6-O-1, *Custody Transfer and Compressed Bundle Status
  Reporting*

The objective is to separate the CCSDS material into three related IETF
specifications:

- Bundle Sequence Identification
- Custody Transfer
- Compressed Bundle Status Reporting

## Document Relationships

The Bundle Sequence Identification draft defines the common:

- Bundle Sequence Number (BSN)
- Bundle Sequence ID (BSID)
- Bundle sequence range
- Bundle sequence collection

framework used by the other specifications.

The Custody Transfer and Compressed Bundle Status Reporting drafts
normatively depend on the Bundle Sequence Identification draft and reuse
its definitions, terminology, encoding rules, and CDDL structures.

## Rights and Contributions

This repository contains material intended for contribution to the IETF
standards process.

Contributions are subject to the applicable IETF contribution rules,
including:

- BCP 78
- BCP 79
- The IETF Trust Legal Provisions in effect at the time of contribution

This repository does not apply a repository-wide software license to the
Internet-Draft text. Rights and permissions for contributed
Internet-Draft material are governed by the applicable IETF Trust and
IETF process rules.

Contributors must have the right to submit their contributions and
should understand that submitted material may be incorporated into IETF
documents under the applicable IETF Trust terms.

The generated RFCXML uses `ipr="trust200902"`, which applies the
standard IETF Trust copyright and licensing provisions for
Internet-Drafts and RFCs. Generated Internet-Drafts therefore include
the standard IETF legal notices produced by the IETF toolchain.

## Status

These drafts are individual submissions and have not been adopted by the
DTN Working Group.

They do not represent a consensus position of the IETF or the DTN
Working Group.

Implementation Status sections are included to assist technical
evaluation and interoperability review during draft development and are
intended to be removed before RFC publication.
