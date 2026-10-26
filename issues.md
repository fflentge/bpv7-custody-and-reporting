# Open Issues

This file tracks editorial, technical, interoperability, and publication
issues across the three drafts.

## General

- [ ] Expand `traceability.md` from section-level to requirement-level
  traceability.
- [ ] Run the current IETF author-tool and Datatracker submission checks
  before posting `-00`.
- [ ] Replace the inline companion-draft reference with a canned BibXML
  reference after the Bundle Sequence Identification draft is posted.

## Bundle Sequence Identification

- [x] Confirm that permitting an empty sequence collection is
  consistently reflected in prose and CDDL. (Verified: prose says
  "zero or more" and "An empty collection is permitted"; CDDL uses
  `[* seq]`.)
- [ ] Review whether fragmentation restrictions belong entirely in the
  common draft or partly in consuming specifications or both.

## Custody Transfer

## Compressed Bundle Status Reporting

- [ ] CRS event codes and relation to IANA Status Report Reason Codes.
  (Renamed from "Status Report Reason Codes" to "CRS Event Codes" and
  clarified as a distinct code space; still to decide: register a new
  IANA registry for CRS event codes or keep them specification-local.)

## IANA

- [ ] Status Report Reason Codes
- [ ] Do we need a registry for custody signals

## Publication and Repository

- [ ] Remove Implementation Status sections before RFC publication, not
  before working-group evaluation.
