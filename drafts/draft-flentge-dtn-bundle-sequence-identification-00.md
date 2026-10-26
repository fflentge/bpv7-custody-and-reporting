---
title: "Bundle Sequence Identification for Bundle Protocol Version 7"
abbrev: "Bundle Sequence Identification"
docname: draft-flentge-dtn-bundle-sequence-identification-00
category: std
submissiontype: IETF
consensus: true
ipr: trust200902
area: Internet
workgroup: "Delay/Disruption Tolerant Networking"

keyword:

  - DTN
  - Bundle Protocol
  - BPv7

author:
  -

    ins: F. Flentge
    name: Felix Flentge
    organization: European Space Agency
    email: felix.flentge@esa.int

normative:
  RFC2119:
  RFC8174:
  RFC8610:
  RFC8949:
  RFC9171:

informative:
  RFC7942:
  CCSDS-734.6-O-1:
    title: >
      Custody Transfer and Compressed Bundle Status Reporting,
      Experimental Specification
    author:
      -
        org: "Consultative Committee for Space Data Systems"
    date: 2026-06
    target: "<https://ccsds.org/publications/orangebooks/entry/4868/>"
    seriesinfo:
      CCSDS: "734.6-O-1"

--- abstract

This document defines compact sequence identifiers, ranges, and
collections for referring to one or more Bundle Protocol Version 7
bundles. The mechanism supports efficient signaling and enables ordered
reception, duplicate suppression, and gap detection.

--- middle

# Introduction {#intro}

Bundle Protocol Version 7 (BPv7) identifies a bundle using its source
node ID, creation timestamp, and, for fragments, fragment information.
Some protocol functions need a compact way to identify ordered groups of
bundles and ranges within those groups. This document defines Bundle
Sequence Numbers (BSNs), Bundle Sequence IDs (BSIDs), bundle sequences,
bundle sequence ranges, and bundle sequence collections for that
purpose. The mechanism is derived from the corresponding CCSDS
experimental specification {{CCSDS-734.6-O-1}}.

The definitions in this document are intended for use by BPv7 extension
specifications. They do not change the identity rules of {{RFC9171}} and
do not by themselves define a new extension block or administrative
record.

# Conventions and Terminology {#conventions}

{::boilerplate BCP14}

Block Source Administrative Endpoint ID (AEID) : An endpoint ID of the
administrative element of the BP agent that assigns a Bundle Sequence
Number and inserts the corresponding extension block.

Bundle Sequence Counter (BSC) : A counter that supplies Bundle Sequence
Numbers for one protocol function and one sequence-identification
context.

Bundle Sequence ID (BSID) : An unsigned integer identifying a Bundle
Sequence Counter. The value zero indicates bundle destination-based
counter selection.

Bundle Sequence Number (BSN) : An unsigned integer obtained from a
Bundle Sequence Counter and carried in an extension block.

# Applicability {#applicability}

The mechanism is suitable where a protocol function benefits from
compact signaling of bundle ranges, ordered reception, duplicate
suppression, or gap detection. Counter scope, persistence, and maximum
values require operational coordination. A consuming specification MUST
define how sequence information is carried and how its processing
context is established.

# Bundle Sequence Counters (BSC) and Bundle Sequence Numbers (BSN) {#counters}

Bundle Sequence Counters (BSCs) provide a Bundle Protocol Agent with
integer sequence numbers for use in extension blocks. When a node
inserts the current value of a counter into an extension block as a BSN,
it MUST increment the BSC by one. A BSC MAY wrap to zero after reaching
a configured maximum value of 2^8, 2^16, 2^32, or 2^64. The maximum MUST
be large enough that a BSN is not reused while a bundle or
administrative record containing the earlier value can remain relevant.

A node MAY maintain multiple BSCs. Each BSC MUST be qualified either by
a positive Bundle Sequence ID (BSID) or by a destination endpoint ID
(EID), i.e. an EID used as a destination in a bundle's primary header.
The use of a destination EID to qualify a BSC SHALL be indicated by BSID
'0' whenever required. BSC SHALL be further qualified by an
Administrative Endpoint ID (AEID) of the Bundle Agent maintaining the
counter. An administrative element may be registered under multiple
AEIDs. Each AEID identifies a distinct BSC context. In addition,
separate protocol functions, such as custody transfer or compressed
bundle status reporting, MUST use separate BSCs.

As a result, each Bundle Sequence Counter (BSC) and the Bundle Sequence
Numbers (BSNs) it provides are uniquely identified by one of the
following:

1. A Block Source Administrative Endpoint ID (AEID) together with a
   positive Bundle Sequence ID (BSID).

2. A Block Source Administrative Endpoint ID (AEID) together with an
   endpoint ID (EID) when BSID is zero.

Within one consuming protocol function and during the relevant bundle
lifetime, sequence information identifies a bundle by the block source
AEID, the BSN, and either the destination EID when BSID is zero or the
positive BSID when BSID is non-zero. Sequence identification does not
replace the BPv7 bundle identity defined by {{RFC9171}}.

Whenever a BSN is used in an extension block, the full identification of
that BSN MUST be available to any processing bundle node by only
processing the bundle. This MAY be achieved by providing the AEID and
BSID or endpoint ID within the extension block. AEID MAY also be
provided implicitly by the bundle source node ID in the primary block if
it is an administrative endpoint ID. A qualifying endpoint ID MAY be the
destination endpoint ID in the primary block.

Implementations SHOULD preserve BSC state across restart. If state
cannot be preserved, an operator MUST prevent ambiguous reuse, for
example by waiting until prior values cannot remain relevant, changing
the block source AEID, or selecting a new positive BSID.

# Bundle Sequences and Collections {#sequences}

BSNs are used to refer to bundle sequences and collections of such
sequences. Using CBOR as defined by {{RFC8949}}, a bundle sequence SHALL
be a definite-length CBOR array of three or four items:

* The first item SHALL either be a positive BSID as a CBOR unsigned
  integer or an EID as a CBOR encoded endpoint ID.
* The second item SHALL be the first BSN as a CBOR unsigned integer.
* The third item SHALL be the length of the sequence, a CBOR unsigned
  integer, or a range as defined below.
* The optional fourth item is the block source AEID as a CBOR encoded
  endpoint ID. A consuming specification MUST state whether the block
  source AEID is present or implicit.

A range SHALL be a definite-length CBOR array containing an odd number
of CBOR unsigned integers. The values SHALL alternately specify included
and excluded subsequence lengths, beginning and ending with an included
length. The first BSN applies to the first element of the first included
subsequence, for example:

* 1st included subsequence length;
* 1st excluded subsequence length;
* 2nd included subsequence length;
* 2nd excluded subsequence length;
* 3rd included subsequence length, etc.

A bundle sequence collection SHALL be a definite-length CBOR array
containing zero or more bundle sequences. An empty collection is
permitted. Sequences in a collection need not use the same identifier or
block source AEID. A receiver MUST reject a sequence as malformed if an
included or excluded length is zero, if a range has even length, if
arithmetic overflows, or if the sequence does not meet the consuming
specification's AEID rules.

# Fragmentation {#fragmentation}

A bundle containing an extension block that uses this
sequence-identification mechanism MUST NOT be fragmented. Extension
blocks using this specification MUST NOT be added to a fragment and MUST
NOT be processed in a fragment. Sources SHOULD set the Bundle Must Not be
Fragmented flag. Convergence-layer segmentation is
unaffected.

# CDDL {#cddl}

The following CDDL uses the CDDL notation of {{RFC8610}} and the EID
rule defined by {{RFC9171}}.

~~~ cddl
;Bundle Sequence Collection
seq-collection = [* seq]

;Bundle Sequence
seq = [
  seq-id-ref: (uint .gt 0) / eid,
  seq-start: seq-num,
  range: seq-range / (uint .gt 0),
  ? blk-source: eid
]

;Bundle Sequence Range
seq-range = [
  incl: (uint .gt 0),
  +(excl: (uint .gt 0), incl: (uint .gt 0))
]

;Bundle Sequence Number
seq-num = uint
~~~

# IANA Considerations {#iana}

This document requests no IANA action.

# Security Considerations {#security}

Forged, replayed, or ambiguously reused sequence information can cause
incorrect operation of protocol functions that rely on the mechanisms
defined in this specification.

# Operational and Manageability Considerations {#manage}

Management information SHOULD expose BSC values, configured moduli,
persistence status, restart events, rejected or malformed sequences,
detected wraparound, and retained sequence state. Operators SHOULD
document the assignment and purpose of positive BSIDs.

# Implementation Status {#impl}

This section records implementation experience in accordance with
{{RFC7942}} and is intended to be removed before publication as an RFC.

The European Space Agency Bundle Protocol implementation includes
separate counter maps for custody transfer and compressed reporting,
sequence-number generation and wraparound handling, and encoding and
decoding of sequence structures. Unit and system tests have been used to
validate these functions.

--- back

# Acknowledgements {#acknowledgements}

The author would like to acknowledge the substantial technical
contributions of Aida Manole, Alice LeBihan, and Yanik Jeck to the
development, review, discussion, and refinement of the mechanisms
specified in this document. Their contributions to the corresponding
CCSDS work significantly influenced the design and maturation of this
specification.
