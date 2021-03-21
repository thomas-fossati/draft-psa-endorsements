---
title: Arm's Platform Security Architecture (PSA) Attestation Verifier Endorsements
abbrev: PSA Endorsements
docname: draft-xyz-rats-psa-endorsements
date: {DATE}
category: info
ipr: trust200902
area: Security
workgroup: RATS

stand_alone: yes
pi:

  rfcedstyle: yes
  toc: yes
  tocindent: yes
  sortrefs: yes
  symrefs: yes
  strict: yes
  comments: yes
  text-list-symbols: -o*+
  docmapping: yes

author:

-
  name: Thomas Fossati
  org: Arm Ltd
  email: thomas.fossati@arm.com

-
  name: Yogesh Deshpande
  org: Arm Ltd
  email: yogesh.deshpande@arm.com

normative:
  PSA-TOKEN: I-D.tschofenig-rats-psa-token

informative:
  SEMA-VER:
   target: https://semver.org
   title: Semantic Versioning 2.0.0
   author:
     -
       ins: T. Preston-Werner
       name: Tom Preston-Werner
   date: 2020

--- abstract

This memo describes a CoMID profile to convey PSA Endorsements.

PSA Endorsements comprise reference values, cryptographic key material and
certification status information that a Verifier needs in order to appraise PSA
Evidence.

--- middle

# Introduction

PSA Endorsements comprise reference values, cryptographic key material and
certification related information that a Verifier needs in order to appraise
Evidence produced by a PSA device {{PSA-TOKEN}}.

This memo profiles and extends the CoMID data model to accommodate PSA specific
requirements.

# Conventions and Definitions

{::boilerplate bcp14}

The reader is assumed to be familiar with the terms defined in Section 2.1 of
{{PSA-TOKEN}}.

# PSA Endorsements
{: #sec-psa-endorsements }

PSA Endorsements describe an attesting device in terms of the hardware and
firmware components that make up its PSA Root of Trust (RoT).  This includes
the identification and expected state of the device as well as the
cryptographic key material needed to verify Evidence signed by the device's PSA
RoT.  Additionally, PSA Endorsements can include information related to the
certification status of the attesting device.

There are two basic types of PSA endorsements:

* Reference Values ({{sec-ref-values}}), i.e., measurements of the PSA RoT
  firmware;
* Identity Claims ({{sec-identity}}), i.e., cryptographic keys that can be used
  to verify signed Evidence produced by the PSA RoT.

## Reference Values
{: #sec-ref-values}

Reference Values carry measurements and other metadata associated with the
updatable firmware in a PSA RoT.  When appraising Evidence, the Verifier
compares Reference Values against the values found in the Software Components
of the PSA token (see Section 3.4.1 of {{PSA-TOKEN}}).  The PSA RoT
Implementation ID (see Section 3.2.2 of {{PSA-TOKEN}}) provides the identifier
for the module to which the measurements are attached.

Each measurement is encoded in a CoMID reference value.  Specifically:

* The Implementation ID is encoded using the module type (2) entry in the
  `element-name` map with a `tagged-impl-id` type;
* The raw measurement is encoded in the `digests-entry` in the `element-value`
  map;
* The metadata associated with the measurement are encoded in a
  `psa-refval-meta` structure which extends the `reference-value` map

The `psa-refval-meta` map is as follows:

~~~
{::include psa-ext/refval-meta.cddl}
~~~

The semantics of the codepoints in the `psa-refval-meta` map is the same as the
`psa-software-component` map defined in Section 3.4.1 of {{PSA-TOKEN}}.

The example in {{ex-reference-value}} shows a CoMID reference value carrying a
firmware measurement associated with Implementation ID
`acme-implementation-id-000000001`.

~~~
{::include examples/ref-value.diag}
~~~
{: #ex-reference-value title="Example Reference Value"}

### Firmware Updates and Patches
{: #sec-fw-evo}

Firmware RoT descriptors that are part of the same upgrade chain can be linked
together using one of `comid-patches` or `comid-updates` relations, depending on
the precise nature of their relationship.  For example, if using semantic
versioning {{SEMA-VER}}, a bump in the MINOR version number would be associated
with a `comid-updates` relation, whereas an increase in the PATCH indicator
would have a corresponding `comid-patches` relation between the involved
components.  Note that `comid-updates` relations would only occur between
firmware RoT descriptors that have PATCH number 0 and "adjacent" MINOR numbers
as illustrated in {{fig-updates-patches}}.  Note that changing the MAJOR
version number would typically result in a separate product / upgrade chain.

~~~ goat
{::include art/updates-patches.txt}
~~~
{: #fig-updates-patches title="Updates, Patches Relations and Semantic Versioning"}

The Reference Value CoMID of the patching or updating firmware has a
`linked-tag-entry` map populated as follows:

* key 0 contains the tag identifier of the Reference Value CoMID of the patched
  or updated firmware;
* key 1 contains one of `comid-patches` or `comid-updates` relations.

{{ex-linked-tag}} provides an example of a Reference Value CoMID patching
another Reference Value CoMID with a UUID tag identifier
`3f06af63-a93c-11e4-9797-00505690773f`.

~~~ goat
{::include examples/linked-tag.diag}
~~~
{: #ex-linked-tag title="Example linked tag in a patch Reference Value CoMID"}

#### Update Graph

{{fig-device-refval-updates}} illustrates the "update" graph for the firmware
components associated with a given PSA hardware RoT.  Each node in the graph is
the Reference Value CoMID associated with a specific version of one firmware
component. Each tagged edge is the CoMID-to-CoMID link relation describing an
update or patch action on the target node by the source node.

~~~ goat
{::include art/one-comid-per-refval-updates.txt}
~~~
{: #fig-device-refval-updates title="Firmware update graph"}

### CoMID Layout

Depending on the firmware update strategy, Endorsers have the following
two packing options:

1. Put multiple Reference Values in one CoMID;
2. Use one CoMID for each Reference Value.

The first packing option MAY be used if the device firmware is made of
separately measurable components and these components are always installed
together in a single software update operation.  If differential software
updates are possible (or if there is only one measurable firmware component),
Endorsers MUST use the second packing option.

## Identity
{: #sec-identity}

Identity Claims carry the verification key associated with the Initial
Attestation Key (IAK) of a PSA device.

Each verification key is encoded alongside the corresponding device Instance ID
in a CoMID identity claim.

The Instance ID is encoded using `tagged-ueid` as `$device-id-type`.

The IAK public key is encoded as a COSE Key according to Section 7 of
{{!RFC8152}} and wrapped in the `COSE_KeySet`.  The number of items in the
`COSE_KeySet` MUST be 1.

The example in {{ex-identity-claim}} shows a CoMID identity claim carrying a
secp256r1 EC public IAK associated with Instance ID `4ca3...d296`.

~~~
{::include examples/instance-pub.diag}
~~~
{: #ex-identity-claim title="Example Identity Claim"}

### CoMID Layout

An Identity CoMID can carry as many Identity Claims as needed.

## Example

TODO

# Security Considerations

TODO

# IANA Considerations

TODO

# Acknowledgements
{: numbered="no"}

John Mattsson was nice enough to point out the need for this being documented.
