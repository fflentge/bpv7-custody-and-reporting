---
title: "Custody Transfer for Bundle Protocol Version 7"
abbrev: "BPv7 Custody Transfer"
docname: draft-flentge-dtn-bpv7-custody-transfer-00
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
  RFC9172:
  I-D.flentge-dtn-bundle-sequence-identification:
    title: "Bundle Sequence Identification for the Bundle Protocol Version 7"
    author:
      -
        ins: F. Flentge
        name: Felix Flentge
        org: European Space Agency
    date: 2026-10-06
    seriesinfo:
      Internet-Draft: "draft-flentge-dtn-bundle-sequence-identification-00"

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
    target: "https://ccsds.org/publications/orangebooks/entry/4868/"
    seriesinfo:
      CCSDS: "734.6-O-1"

--- abstract

This document defines custody transfer for Bundle Protocol Version 7. A
Custody Transfer Extension Block is defined to request custody transfer
of a bundle, and a Compressed Custody Signal in the form of an
administrative record is used to report acceptance or rejection for
multiple bundles.

--- middle

# Introduction {#intro}

BPv7, as defined in {{RFC9171}}, does not include the custody-transfer
mechanism defined for BPv6. Building on the corresponding CCSDS
experimental specification {{CCSDS-734.6-O-1}}, this document defines a
BPv7 custody-transfer extension in which a Custody Transfer Extension
Block (CTEB) requests transfer of retransmission responsibility and a
Compressed Custody Signal (CCS) reports acceptance or rejection for
multiple bundles.

This document depends on the sequence-identification framework in
{{I-D.flentge-dtn-bundle-sequence-identification}}.

# Conventions and Terminology {#conventions}

{::boilerplate BCP14}

Block Source Administrative Endpoint ID (AEID) : An endpoint ID of the
administrative element of the BP agent that assigns a Bundle Sequence
Number and inserts the corresponding Custody Transfer Extension Block.

Compressed Custody Signal (CCS): An administrative record sent to the
current custodian of a bundle to indicate acceptance or rejection of
custody.

Current Custodian: A node retaining a bundle after requesting onward
custody.

Prospective Custodian: A node deciding whether to accept custody.

Custody Transfer (CT): Transfer of responsibility for retaining and
reliable transmission of a bundle from one BP node to another. Typically
this is achieved through keeping a copy of the bundle and
re-transmitting the bundle in case no custody acceptance signal is
received. It can also be achieved if the use of reliable convergence
layers can be guaranteed to the next custodian of destination node.
Still, custody transfer may fail and it does not guarantee end-to-end
reliability. It is rather an efficiency mechanism as it allows
re-transmission from an intermediate node and may be used together with
end-to-end reliability mechanisms, such as delivery reporting, where
required.

Custody Transfer Extension Block (CTEB): A BPv7 extension block which
requests forwarding bundle nodes to take custody of a bundle.

# Applicability Statement {#applicability}

This mechanism is intended primarily for relatively small, well-managed
DTNs in which participants, routing expectations, storage policies, and
operational responsibilities are known. It does not prescribe the use of
custody timers or solve re-forwarding time estimation for large-scale
open DTNs. Nodes can forward a CTEB without implementing this
specification according to BPv7 extension-block processing, but gaps in
support can reduce efficiency or prevent transfer of custody.

# Protocol Overview {#overview}

A node requests custody by inserting a CTEB. A downstream node accepts
or rejects custody and reports the disposition in a CCS addressed to the
block source AEID. An accepting custodian retains the bundle and, unless
reliable delivery to the destination is otherwise assured, requests
custody from a downstream node. The current custodian releases its
custody state only after an accepting CCS or bundle expiration.

# Custody Transfer Extension Block (CTEB) {#cteb}

Custody Transfer is requested by adding a Custody Transfer Extension
Block (CTEB). The CTEB MUST use the BPv7 canonical block format
according to {{RFC9171}}. Block Type 13 as assigned by IANA for the
CTEB MUST be used. A bundle MUST NOT contain more than one CTEB.

Using CBOR as defined by {{RFC8949}}, the block-type-specific data MUST
be a definite-length CBOR byte string containing a definite-length CBOR
array with the following three elements:

* The first item SHALL be a Bundle Sequence Number (BSN), a CBOR
unsigned integer, as specified in
{{I-D.flentge-dtn-bundle-sequence-identification}}.
* The second item SHALL be a Bundle Sequence ID (BSID), a CBOR unsigned
integer, as specified in
{{I-D.flentge-dtn-bundle-sequence-identification}}.
* The third item SHALL be the block source AEID, a CBOR encoded endpoint
ID, as specified in {{I-D.flentge-dtn-bundle-sequence-identification}}.

The BSID '0' SHALL be used to indicate that the BSN is qualified by the
destination EID in the primary header.

A node that cannot parse the array, encounters additional or missing
elements, or finds an invalid EID MUST treat the block as malformed and
apply the block processing control flags as specified by BPv7.

# Compressed Custody Signal (CCS) {#ccs}

The Compressed Custody Signal (CCS) is used to inform the current
custodian about custody acceptance or refusal. A CCS MUST be a BPv7
administrative record. Administrative Record Type 13 as assigned by IANA
for the CCS MUST be used.

The content of the CCS administrative record MUST be a CBOR map with the
following key/value pairs:

* Disposition Codes as keys

  * 1 - *Custody Acceptance* (no further information); an unsigned CBOR
integer; values above 1 are reserved for future use and may provide
additional information for acceptance.

  * -1 - *Custody Rejection* (no further information); a negative CBOR
integer; values below -1 are reserved for future use and may provide
additional information for rejection.

> A receiver MUST use the sign of the disposition code to determine
> whether custody was accepted or rejected. A positive value indicates
> acceptance and a negative value indicates rejection.

* Bundle Sequence Collections as specified in
{{I-D.flentge-dtn-bundle-sequence-identification}} as values.

Bundle sequences in a CCS MUST NOT contain block source AEIDs. The CCS
destination is the block source AEID from the CTEB which will be the
destination EID in the primary block of the bundle, making that AEID
implicit.

# Custody Procedures {#procedures}

## Request and Decision {#request-decision}

Any node MAY request custody by inserting a CTEB. A non-destination node
receiving a valid CTEB MUST decide whether to accept or reject custody.
The custody decision will depend on mission or local network policies
and other constraints. A node may take custody of a bundle when there is
reasonable likelihood that it can be forwarded to a next custodian
successfully, based on a bundle lifetime, upcoming contacts, past
experiences, etc. At a minimum, the node must be capable of storing the
bundle for eventual re-transmission. It is RECOMMENDED to document the
conditions for accepting or rejecting custody.

A destination MUST NOT deliver a bundle carrying a CTEB without
accepting custody.

## Acceptance {#acceptance}

On acceptance, a node MUST retain the information required to generate
an acceptance CCS and MUST remove the received CTEB. Unless onward
delivery to the bundle destination or a next custodian is reliably
assured, the bundle agent MUST add a new CTEB using an EID in which its
administrative element is registered in as block source AEID before
forwarding and MUST retain the bundle until it receives an accepting CCS
or the bundle expires.

## Rejection {#rejection}

A node rejecting custody SHOULD retain enough information to generate a
rejection CCS. It MAY forward or delete the bundle.

## Duplicate Handling {#duplicate-handling}

If the custodian detects a duplicate bundle based on the sequence number
contained in the CTEB, it MUST (re-)send the acceptance signal and
discard the duplicate. A node MAY maintain a list of bundles for which
it has accepted and transferred custody. This enables the node to
suppress delayed re-forwarded bundles by resending an acceptance signal
and discarding the bundle.

## Signal Generation and State Release {#signal-state}

A node SHALL generate and transmit CCSs from stored disposition
information according to configuration or external events. Signal
generation and transmission MAY be based on:

* periodic timers,
* size constraints for the CCS (bundle size or number of reported
  bundles), supplemented by a timer to prevent indefinite delays when
  the size limit is not reached but there are no additional bundles to
  report,
* external events such as link establishment or explicit commands to
send CCS.

Upon receiving a valid accepting CCS for a bundle, the current custodian
MUST release the corresponding custody retention state. A rejection CCS
for a bundle MUST NOT cause release of custody state.

## Re-forwarding {#reforwarding}

If an acceptance signal for a bundle is not received, a custodian SHOULD
re-forward the bundle. Triggers for re-forwarding MAY include:

* timer expiration,
* detected gaps in received acceptance sequences,
* explicit commands to re-forward bundles for which no acceptance signal
  has been received,
* contact events, or
* convergence-layer failures.

# Interaction with End-to-End Reliability {#end-to-end-reliability}

Custody transfer localizes recovery between custodians but does not
guarantee end-to-end delivery, because a custodian may delete bundles or
lose state information. Delivery and deletion reporting can complement
custody. A source node can then retransmit a bundle in case custodial
transfer fails.

# Fragmentation {#fragmentation}

A bundle containing a CTEB MUST NOT be fragmented. A CTEB MUST NOT be
added to or processed in a fragment. Sources SHOULD set the Bundle Must
Not be Fragmented flag.

# CDDL {#cddl}

The following CDDL uses the CDDL notation of {{RFC8610}} and the rules
defined by {{RFC9171}}.

~~~ cddl
;CTEB
$extension-block /= extension-block-use<13, embedded-cbor<cteb-data>>

cteb-data = [seq-num: uint, seq-id: uint, blk-source: eid]

;CCS
$admin-record /= [13, custody-signal-content]

custody-signal-content = {
  + uint .gt 0 => seq-collection, ; custody accepted
  + nint => seq-collection        ; custody rejected
}
~~~

# IANA Considerations {#iana}

IANA has assigned Bundle Block Type 13 to the Custody Transfer Extension
Block and Bundle Administrative Record Type 13 to the Compressed Custody
Signal, with CCSDS 734.6-O-1 as the current reference. IANA is requested
to add this document as a reference for both registrations upon
publication as an RFC.

# Security Considerations {#security}

A forged acceptance can cause premature deletion of retained bundles,
while forged rejection can cause unnecessary re-forwarding. Unauthorized
CTEBs can consume storage and communications resources, and a malicious
custodian can accept and silently discard bundles.

It is RECOMMENDED to use BPSec {{RFC9172}} integrity protection to
authenticate CTEBs and CCS administrative records where these threats
are relevant.

# Operational and Manageability Considerations {#manage}

Implementations SHOULD expose retained-custody volume, pending
acceptance and rejection information, signal aggregation timers and
thresholds, re-forward counts, expirations, malformed blocks and
signals, authorization failures, and storage-related rejections.
Operators SHOULD document acceptance and re-forwarding policy.

# Implementation Status {#impl}

This section records implementation experience in accordance with
{{RFC7942}} and is intended to be removed before publication as an RFC.

The European Space Agency Bundle Protocol implementation supports CTEB
and CCS encoding and processing, acceptance and rejection policy,
custody retention constraints, timer- and signal-triggered
re-forwarding, duplicate handling, and compressed signal aggregation. It
has been exercised in simulations including a lunar relay, rover, ground
station, and control centers.

NASA Goddard Space Flight Center BPNode Build 7.0.5 implemented the
custody-transfer features and was tested aboard the CAPSTONE spacecraft
during multiple uplink and downlink passes at lunar distances. The
implementation information reflects the status reported in June 2026.

--- back

# Acknowledgements {#acknowledgements}

The author would like to acknowledge the substantial technical
contributions of Aida Manole, Alice LeBihan, and Yanik Jeck to the
development, review, discussion, and refinement of the mechanisms
specified in this document. Their contributions to the corresponding
CCSDS work significantly influenced the design and maturation of this
specification.
