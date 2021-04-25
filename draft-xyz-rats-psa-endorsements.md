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

-
  name: Henk Birkholz
  org: Fraunhofer SIT
  email: henk.birkholz@sit.fraunhofer.de

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

# PSA Supply Chain Provisioning Actors

{: #sec-supplychain}
There are various stages of PSA provisioning, performed by one or more actors at a different stage of a PSA Device.

PSA Endorsements are conveyed using Concise Reference Integrity Manifest (CoRIM) structure, using CBOR Object Signing and 
Encryption (COSE) protocol. The PSA Endorsement CoRIM is organised in a following manner:

* A CoRIM Header which comprises of security information for the payload namely, security algorithm used, key identifier of CoRIM issuer and a corim-meta-map which consists of details about the signer and also CoRIM validity period.

* A CoRIM payload which is a structure comprising of an array of one more CoMID's carrying the actual endorsements.

* Signature of the CoRIM Header and Payload which is signed by the Endorser, using its key credentials.

The above structure is transmitted as a CBOR Message.

The Verifier upon receiving the CBOR Message will first Unmarshal its contents to construct the original structure.
It then verifies the signature received in the Header using the Public key of the signing entity, i.e the endorser.
If signature matches, the actual endorsements are provisioned in the verifier.

The following are the possible provisioning actors and enlist the specific information they provision in a verifier.

## Original Equipment Manufacturer (OEM)

This entity is responsible for provisioning of the class endorsements, i.e. the endorsements that define the Reference Value claims for the base composition of a PSA RoT device. These Claims carry information about Immutable RoT, i.e PSA Platform as well as the software measurements belonging to the Mutable RoT, i.e the baseline firmware components.
How these measurements are populated in a set of CoMID's depend upon the Provisioning Model chosen by the endorser.
Subsequently a CoRIM Manifest is created and transmitted to the Verifier, as mentioned above.

## Original Device Manufacturer (ODM)

The role of ODM is at a subsequent stage in the provisioning sequence. When multiple instances of the same device class (template) are created, this entity provisions the Identity Claims associated to each device.
Identity Claims carry the verification key associated with the Initial Attestation Key (IAK) of a PSA device.

Each verification key is encoded alongside the corresponding device Instance ID in a CoMID identity claim.

## Independent Software Vendor (ISV)

It is assumed that future modifications to the baseline firmware components provisioned by OEM can be independently
maintained by ISV's. This actor will provision future minor modifications to the baseline firmware components
via generating new CoMIDs which are patches to the baseline software component CoMIDs.
Any major revision of the software component will be marked via new CoMID which are updates to the baseline software component CoMIDs.

## Certification Authority

PSA devices undergo certification for either the PSA platform or specific measured firmware components or to the entire PSA device. Once the Certification is complete, the Certification Authority issues certificates and provisions the metadata for
certificates into the verification service, using Certification CoMIDs. Within a CoMID, the Metadata is carried as Endorsed Claim. The CoMID is carried ina CoRIM signed by the Certification Authority.

## Example

TODO

# Security Considerations

TODO

# IANA Considerations

TODO

# Acknowledgements
{: numbered="no"}

John Mattsson was nice enough to point out the need for this being documented.
