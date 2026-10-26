---
title: "Compressed Bundle Status Reporting for Bundle Protocol Version 7"
abbrev: "Compressed Bundle Status Reporting"
docname: draft-flentge-dtn-compressed-status-reporting-00
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
  I-D.flentge-dtn-bpv7-custody-transfer:
    title: "Custody Transfer for Bundle Protocol Version 7"
    author:
      -
        ins: F. Flentge
        name: Felix Flentge
        org: European Space Agency
    date: 2026-10-06
    seriesinfo:
      Internet-Draft: "draft-flentge-dtn-bpv7-custody-transfer-00"

--- abstract

This document defines compact, aggregated status reporting for Bundle
Protocol Version 7. A Compressed Reporting Extension Block assigns
sequence information and optionally requests reports, while a Compressed
Reporting Signal reports events for multiple bundles.

--- middle

# Introduction {#intro}

Standard BPv7 status reporting, as defined in {{RFC9171}}, generates one
report bundle for each reportable event such as reception, forwarding,
delivery or deletion of a bundle. As this can create excessive network
traffic, bundle status reports must be disabled by default. Building on
the corresponding CCSDS experimental specification {{CCSDS-734.6-O-1}},
this document defines compact reporting in which a Compressed Reporting
Extension Block (CREB) supplies sequence information and optionally
requests reports, and a Compressed Reporting Signal (CRS) aggregates
events for multiple bundles.

This document depends on the sequence-identification framework in
{{I-D.flentge-dtn-bundle-sequence-identification}}.

# Conventions and Terminology {#conventions}

{::boilerplate BCP14}

Block Source Administrative Endpoint ID (AEID): An endpoint ID of the
administrative element of the BP agent that assigns a Bundle Sequence
Number and inserts the corresponding Compressed Reporting Extension
Block.

Compressed Reporting Signal (CRS): An administrative record sent to a
report-to endpoint to provide bundle status information on a set of
bundles.

Compressed Reporting Extension Block (CREB): A BPv7 extension block which
requests compressed reporting of bundle status.

# Applicability {#applicability}

The mechanism is intended for DTNs where aggregating reports materially
reduces signaling overhead. CREBs can be forwarded by nodes that do not
implement this specification, but reports are generated only by
supporting nodes. Deployment policy must account for incomplete support
and possible loss or delay of reporting signals.

# Compressed Reporting Extension Block {#creb}

Compressed Reporting is requested by adding a Compressed Reporting
Extension Block (CREB). The CREB MUST use the BPv7 canonical block
format according to {{RFC9171}}. Block Type 14 as assigned by IANA for
CREB MUST be used. A bundle MAY contain multiple CREBs inserted by the
same or different nodes.

Using CBOR as defined by {{RFC8949}}, the block-type-specific data MUST
be a definite-length CBOR byte string containing a definite-length array
of one to five elements as defined below.

## 1-Element Form: Sequence Number Only {#sequence-only}

For an array-length of 1, the array SHALL contain:

* Item 1 SHALL be a Bundle Sequence Number (BSN), a CBOR unsigned
integer, as specified in
{{I-D.flentge-dtn-bundle-sequence-identification}}.

The block source AEID SHALL be implicitly given by the source node EID
in the primary block of the bundle. Only the source node MAY use the
1-Element Form. This form does not request creation of aggregate reports
but can, for example, be used by a receiving node to detect gaps in
bundle sequences or restore the order of bundles.

## 2-Element Form: Sequence Number and Identification {#sequence-identification}

For an array-length of 2, the array SHALL contain:

* Item 1 SHALL be as defined in {{sequence-only}}

* Item 2 SHALL be a Bundle Sequence ID (BSID), a CBOR unsigned integer,
as specified in {{I-D.flentge-dtn-bundle-sequence-identification}}.

The block source AEID SHALL be implicitly given by the source node EID
in the primary block of the bundle. Only the source node MAY use the
2-Element Form. This form does not request creation of aggregate reports
but can, for example, be used by a receiving node to detect gaps in
bundle sequences or restore the order of bundles.

## 3-Element Form: Reporting-Request with implicit source {#reporting-request}

For an array-length of 3, the array SHALL contain:

* Item 1 and Item 2 SHALL be as defined in {{sequence-identification}}

* Item 3 SHALL contain the Status Report Request flags which SHALL be
  processed as a bit field indicating the flag values for the following
  reporting requests:

  * Bit 0 - reception;
  * Bit 1 - forwarding;
  * Bit 2 - delivery;
  * Bit 3 - deletion;
  * Bit 4 - custody acceptance;
  * Bit 5 - custody rejection;
  * Bit 6 and higher - reserved for future use.

Custody-related reporting is for informational purposes only and should
not be confused with custody signals that trigger the behavior defined
in Custody Procedures {{I-D.flentge-dtn-bpv7-custody-transfer}}.
The intention is to enable the reporting of custody-related behavior to
a report-to node that is different from the current custodian, which is
the receiver of all custody signals.

Only the bundle source MAY use the 3-Element Form. The block source AEID
and report destination SHALL be implicitly given by the source node EID
in the primary block of the bundle and MUST identify an administrative
endpoint capable of receiving the CRS.

## 4-Element Form: Reporting-Request with explicit block source {#reporting-request-source}

For an array-length of 4, the array SHALL contain:

* Item 1 to Item 3 SHALL be as defined in {{reporting-request}}

* Item 4 SHALL be the block source AEID of the node which inserted the
  CREB, a CBOR encoded endpoint ID as specified in
  {{I-D.flentge-dtn-bundle-sequence-identification}}. CRSs are sent to
  this AEID (see {{processing}}).

## 5-Element Form: Reporting-Request with explicit report-to EID {#reporting-request-report-to}

For an array-length of 5, the array SHALL contain:

* Item 1 to Item 4 SHALL be as defined in {{reporting-request-source}}

* Item 5 SHALL be a report-to EID, a CBOR encoded endpoint ID as
  specified in {{I-D.flentge-dtn-bundle-sequence-identification}}. CRSs
  are sent to this report-to EID (see {{processing}}).

## Malformed CREBs {#malformed-creb}

A node MUST treat a CREB as malformed if its array length is outside one
through five, field types are invalid, reserved flag bits are set
contrary to this specification, or the array form violates the source or
EID constraints. It MUST apply the block processing control flags
according to BPv7 and MUST NOT generate reports from malformed request
data.

# Compressed Reporting Signal {#crs}

The Compressed Reporting Signal (CRS) is used to transmit aggregated
status reports. A CRS MUST be a BPv7 administrative record.
Administrative Record Type 14 as assigned by IANA for the CRS MUST be
used.

The content of the CRS administrative record MUST be a CBOR map with the
following key/value pairs:

* CRS Event Codes as keys; an unsigned CBOR integer

  * 0 - reception;
  * 1 - forwarding;
  * 2 - delivery;
  * 3 - deletion;
  * 4 - custody acceptance;
  * 5 - custody rejection;
  * Values above 5 - reserved for future use;

> A receiver MUST ignore an unrecognized event code while processing
> recognized entries in the same map. CRS event codes are specific to
> this specification and are distinct from the Bundle Status Report
> Reason Codes registered for BPv7 status reports.

* Bundle Sequence Collections as specified in
{{I-D.flentge-dtn-bundle-sequence-identification}} as values.

> A sequence in a CRS MUST include its block source AEID only when the
> report-to EID differs from the administrative endpoint of the node
> that inserted the CREB, namely the 5-Element Form. For the 3- and
> 4-Element Forms, the CRS receiver is the block source and that AEID is
> implicit.

# Reporting Procedures {#processing}

Reception of a valid 3-, 4-, or 5-Element CREB MUST cause a supporting
node to retain the information needed to report each requested event
that occurs. The retained information includes CRS event code, BSN,
BSID, source Node ID, destination EID, Block Source EID and report-to
EID as available and required.

The CRS destination MUST be the bundle's source node ID for a 3-Element
CREB, the block source AEID for a 4-Element CREB, and the report-to EID
for a 5-Element CREB. A node SHALL generate and transmit CRSs from
stored disposition information to the CRS destination according to
configuration or external events. CRS generation and transmission MAY be
based on:

* periodic timers,
* size constraints for the CRS (bundle size or number of reported
  bundles), supplemented by a timer to prevent indefinite delays when
  the size limit is not reached but there are no additional bundles to
  report,
* external events such as link establishment or explicit commands to
  send CRS.

Once a CRS for a specific bundle has been transmitted, no other
reporting signal for this bundle SHOULD be generated with the same
event code.

# End-to-End Use {#end-to-end-use}

Compressed Reporting can be used to realize various End-to-End Services.
Sequence-only CREBs (1- and 2-Element Form) can support in-sequence
delivery, duplicate suppression, and gap detection without CRS
generation. Delivery and deletion CRSs can provide end-to-end accounting
and can be used to trigger retransmission of bundles from the source to
enable reliable bundle delivery. The services described in the following
sections are not mutually exclusive, so they can be combined without the
need for additional extension blocks.

## In-Sequence Delivery

CREB sequence numbers based on separate counters per destination EID
(BSID '0') enable bundle re-ordering at destination. Lost or delayed
bundles can be handled using timeouts.

## Duplicate Suppression

Duplicate suppression works similarly to the in-sequence delivery. When
CREB sequence numbers use separate counters per destination EID (BSID
'0'), duplicated bundles can be detected by the same sequence number and
suppressed. This is more efficient than using time stamps as it allows
more compact storage of information about received bundles.

## Gap Detection

End-to-end gap detection can also be based on BSNs using separate
counters per destination EID (BSID '0'). Out-of-order bundle arrivals
can be addressed by implementing a time window before reporting a gap,
to wait for late arrivals with lower sequence numbers than the current
maximum.

## Bundle Accounting

The use of CRSs for delivery or deletion of bundles allows for
end-to-end accounting of bundles towards the bundle source node (using
{{reporting-request}}), the block source AEID (using
{{reporting-request-source}}), or a different report-to EID (using
{{reporting-request-report-to}}). For delivery reporting, only the
destination node must support CRS. For deletion accounting, both the
destination and deleting nodes must support CRS. If the deleting node
does not support CRS, failed delivery can still be inferred from a
missing delivery report. However, cases where the reporting signal is
lost may result in wrongly assumed delivery failure.

## Reliability

Using the end-to-end accounting mechanism described above, end-to-end
reliability can be provided by re-forwarding a bundle when an expected
delivery report has not been received or the bundle has been reported as
deleted. Re-forwarding a bundle again over the full end-to-end path is
usually inefficient, so this mechanism may be combined with Custody
Transfer as specified in
{{I-D.flentge-dtn-bpv7-custody-transfer}}. In this way,
re-forwarding will typically happen between custodians with
re-forwarding from the source required only if Custody Transfer fails.

# Fragmentation {#fragmentation}

A bundle containing a CREB MUST NOT be fragmented. A CREB MUST NOT be
added to or processed in a fragment. Sources SHOULD set the Bundle Must
Not be Fragmented flag.

# CDDL {#cddl}

The following CDDL uses the CDDL notation of {{RFC8610}} and the rules
defined by {{RFC9171}}.

~~~ cddl
;CREB
$extension-block /= extension-block-use<14, embedded-cbor<creb-data>>

creb-data = [
  seq-num: uint,
  ? seq-id: uint,
  ? status-request-flags: uint,
  ? blk-source: eid,
  ? report-to-eid: eid
]

;CRS
$admin-record /= [14, reporting-signal-content]

reporting-signal-content = {
  0 => seq-collection, 1 => seq-collection,
  2 => seq-collection, 3 => seq-collection,
  4 => seq-collection, 5 => seq-collection,
  * uint => seq-collection
}
~~~

# IANA Considerations {#iana}

IANA has assigned Bundle Block Type 14 to the Compressed Status
Reporting Extension Block and Bundle Administrative Record Type 14 to
the Compressed Reporting Signal, with CCSDS 734.6-O-1 as the current
reference. IANA is requested to add this document as a reference for
both registrations upon publication as an RFC.

# Security Considerations {#security}

Reports can reveal traffic patterns and delivery state. Forged requests
can amplify traffic toward a victim report-to EID, while forged signals
can corrupt accounting or trigger unnecessary retransmission. Nodes MUST
authorize report requests and destinations and MUST bound stored report
state and transmission rate.

Deployments SHOULD use BPSec {{RFC9172}} integrity protection for CREBs
and CRS administrative records where authentication and integrity are
required, and confidentiality protection where reporting data is
sensitive.

# Operational and Manageability Considerations {#manage}

Implementations should expose report aggregation timers and thresholds,
pending report state by destination and event, generated and received
CRS counts, duplicate reports, malformed CREBs and CRSs, authorization
failures, discarded requests, and resource-limit events.

# Implementation Status {#impl}

This section records implementation experience in accordance with
{{RFC7942}} and is intended to be removed before publication as an RFC.

The European Space Agency Bundle Protocol implementation supports CREB
and CRS encoding and processing, sequence-only and reporting-request
forms, event collection, timer- and size-triggered aggregation, and
compressed signal transmission. The mechanisms have been validated with
unit tests, simulations, and a simulated lunar communication scenario
involving a relay orbiter, rover, ground station, and control centers.
The implementation information reflects the status reported in June
2026.

--- back

# Acknowledgements {#acknowledgements}

The author would like to acknowledge the substantial technical
contributions of Aida Manole, Alice LeBihan, and Yanik Jeck to the
development, review, discussion, and refinement of the mechanisms
specified in this document. Their contributions to the corresponding
CCSDS work significantly influenced the design and maturation of this
specification.
