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

PSA Endorsements comprises reference values, cryptographic key material and
certification status information that a Verifier needs in order to appraise PSA
Evidence.

This memo describes the data formats used to convey PSA Endorsements to an Attestation Verifier.
The format presented in this document is a PSA specific profile of CoRIM/CoMID based information model presented in
Trusted Computing Group (TCG) Endorsement Architecture.

--- middle

# Introduction

TCG has defined an Endorsement Architecture. This architecture defines an information model that represents a composition of a device which comprises various hardware, embedded firmware and software elements and their associated endorsements.
In this model, any Hardware and Firmware specific endorsements and certification information metadata are conveyed using Concise Module ID (CoMID) tag. CoMID tag is an abstraction of HW and FW endorsements and certification metadata.

The CoMIDs are bundled together in a CoRIM as a manifest by the Endorser, so that it can be provisioned in a verifier.

This memo profiles and extends the CoMID data model to accommodate PSA specific requirements.

PSA Endorsements comprises reference values, cryptographic key material and
certification related information that needs to be provisioned in a Verifier so that in can appraise
evidence produced by a PSA device {{PSA-TOKEN}}.


# Conventions and Definitions

{::boilerplate bcp14}

The reader is assumed to be familiar with the terms defined in Section 2.1 of
{{PSA-TOKEN}}.

# PSA Endorsements
{: #sec-psa-endorsements }

PSA Endorsements describe an attesting device in terms of the hardware and
firmware components that make up its PSA Root of Trust (RoT). This includes
the identification and expected state of the device as well as the
cryptographic key material needed to verify Evidence signed by the device's PSA
RoT. Additionally, PSA Endorsements can include information related to the
certification status of the attesting device.

There are three basic types of PSA endorsements:

* Reference Values ({{sec-ref-values}}), i.e., measurements of the PSA RoT
  firmware;
* Identity Claims ({{sec-identity}}), i.e., cryptographic keys that can be used
  to verify signed Evidence produced by the PSA RoT and the associated identifiers that
  bind the keys to their device instances.
* Certification Claims ({{sec-certificates}}), i.e., metadata that describe
  the certification status associated with a PSA device.

## Reference Values
{: #sec-ref-values}

Reference Values carry measurements and other metadata associated with the
updatable components in a PSA RoT.  When appraising Evidence, the Verifier
compares Reference Values against the values found in the Software Components
of the PSA token (see Section 3.4.1 of {{PSA-TOKEN}}).  The PSA RoT
Implementation ID (see Section 3.2.2 of {{PSA-TOKEN}}) provides the identifier
for the module to which the measurements are attached.

Each measurement is encoded in a CoMID reference value.  Specifically:

* The Implementation ID is encoded using the `$class-id-type-choice` (2) entry in the
  `element-name-map` with a `tagged-impl-id` type;
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

## Identity
{: #sec-identity}

Identity Claims carry the verification key associated with the Initial
Attestation Key (IAK) of a PSA device.

Each verification key is encoded alongside the corresponding device Instance ID
in a CoMID identity claim.

The Instance ID is encoded using the `$device-id-type-choice` (0) entry in the `identity-claim-map` with a `tagged-ueid-type` type.

The IAK public key is encoded as a COSE Key according to Section 7 of
{{!RFC8152}} and wrapped in the `COSE_KeySet`. The number of items in the
`COSE_KeySet` MUST be 1.

The example in {{ex-identity-claim}} shows a CoMID identity claim carrying a
secp256r1 EC public IAK associated with Instance ID `4ca3...d296`.

An Identity CoMID can carry as many Identity Claims as needed.

~~~
{::include examples/instance-pub.diag}
~~~
{: #ex-identity-claim title="Example Identity Claim"}


## Certification
{: #sec-certificates}

A PSA Certification can certify PSA hardware, software RoT or the complete device.
Specifically, it can certify one of the following:

* The underlying platform, identified by the Impementation ID;
* One or more firmware components of the mutable PSA RoT;
* The entire PSA device.

A PSA Certification claim contains the metadata about the certificate. The claim is 
expressed by creating a new CoMID Tag for provisioning certification details.

The certification status is encoded as a CoMID endorsement as follows:

* The Implementation ID of the PSA RoT to which the certification metadata apply is encoded 
  using the `class-id-type-choice` (2) entry in the `element-name-map` with a `tagged-impl-id` type;

* The metadata associated with the certification is encoded in a `comid.psa-cert-meta` structure
  which extends the `endorsed-value-map` through the `$$endorsed-value-map-extension` socket.
  
* The CoMID MAY contain one or more `linked-tag-map` entries carrying the
  tag id of the CoMID corresponding to the certified module with `$tag-rel-type-choice` set to `comid.supplements`,
  as illustrated in {{fig-cert-link}}.

A PSA Certification data element has the following attributes:

* `cert-level-type-choice`    : PSA certification level.  Acceptable values are x, y, z...
* `cert-num-type`             : A unique number for each certificate
* `cert-issue-date-type`      : Certificate date of issue, formatted as {{!RFC3339}} full-date (e.g., 2020-12-31)
* `cert-test-lab-type`        : Name of the certification lab
* `cert-holder-type`          : Name of Organization which holds the certificate
* `cert-product-type`         : Name of the product been certified
* `cert-hw-version-type`      : Version of Hardware certified
* `cert-sw-version-type`      : Version of Software certified
* `cert-type-type`            : Further details on certification
* `cert-dev-type-type-choice` : Type of certificate, Chip, Device or System Software

The `comid.psa-cert-meta` map is as follows:

~~~
{::include psa-ext/cert-meta.cddl}
~~~

The provisioning linkage of Certification CoMID to the RoT CoMID is illustrated in {{fig-cert-link}}.

~~~
{::include art/cert.txt}
~~~
{: #fig-cert-link title="Certification Link to the RoT been certified"}

The example in {{ex-cert-ext}} shows a CoMID endorsement claim carrying
certification metadata associated to Implementation ID
`acme-implementation-id-000000001`.

~~~
{::include examples/cert-val.diag}
~~~
{: #ex-cert-ext title="Example Certification Claim"}

The example in {{ex-cert-val-link}} shows the link entry to the CoMID tag being supplemented with certification information.

~~~
{::include examples/cert-val-link.diag}
~~~
{: #ex-cert-val-link title="Example Certification CoMID Linkage"}

## PSA Provisioning Model

Two provisioning models are envisioned, for provisioning PSA Endorsements.

* Atomic model ({{sec-atmoic}}), where each measured and updatable component of PSA RoT is expressed independently and hence each component has its own upgrade chain.

* Bundled model ({{sec-bundled}}), where all the measured and updatable components of a PSA RoT are bundled together and are treated as single entity from the point of view of upgrade chain.

The choice between atomic and bundled model depends upon the use case and individual deployment needs. One needs to make a choice at start
before provisioning the endorsements.

### Atomic
{: #sec-atmoic}
In an atomic provisioning model, measurements for each firmware component associated with a hardware RoT is conveyed using a unique CoMID tag. Each tag contains the identifier for the platform RoT associated to the PSA device.
This enables the verifier to link all the firmware components belonging to the same platform and model them as a collection of nodes in a graph.

Each node in the graph is a CoMID, which has a Reference Value Map that contains measurements associated with a specific version of firmware component. Each firmware component can have its own upgrade chain which can be tracked. Each tagged edge is the CoMID-to-CoMID link relation describing an update or patch action on the target node by the source node.

~~~ goat
{::include art/atomic.txt}
~~~
{: #fig-atomic title="Atomic Provisioning Model"}

A limitation of this model is that it may not be able to distinguish between a valid software RoT ( i.e. an
expected combination of software component versions) from an invalid one.

### Bundled
{: #sec-bundled}
In the bundled provisioning model all firmware components associated with a hardware RoT are grouped together in a single
CoMID tag. The CoMID tag contains the identifier for the platform RoT associated to the PSA device. CoMID tag has a Reference Value Map which is used to carry a list of Reference Values ({{sec-ref-values}}). Each entry in the list carries the measurements associated to a firmware component. This model is applicable if the device firmware is made of separately measurable components however these components are always installed together in a single firmware update operation. In this model, the evolution of the versions of firmware component is collectively tracked using the CoMID updates and patches relations.

~~~ goat
{::include art/bundled.txt}
~~~
{: #fig-bundled title="Bundled Provisioning Model"}

Each tagged edge is the CoMID-to-CoMID link relation describing an
update or patch action on the target node by the source node.

### Firmware Updates and Patches

{: #sec-fw-evo}

Firmware measurements that are part of the same upgrade chain can be linked
together using one of `comid.patches` or `comid.updates` relations, depending on
the precise nature of their relationship.  For example, if using semantic
versioning {{SEMA-VER}}, a bump in the MINOR version number would be associated
with a `comid.updates` relation, whereas an increase in the PATCH indicator
would have a corresponding `comid.patches` relation between the involved
components.  Note that `comid.updates` relations would only occur between
firmware measurements that have PATCH number 0 and "adjacent" MINOR numbers
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
* key 1 contains one of `comid.patches` or `comid.updates` relations.

{{ex-linked-tag}} provides an example of a Reference Value CoMID patching
another Reference Value CoMID with tag identifier
`3f06af63-a93c-11e4-9797-00505690773f`.

~~~
{::include examples/linked-tag.diag}
~~~
{: #ex-linked-tag title="Example linked tag in a patch Reference Value CoMID"}

## Example

TODO

# Security Considerations

TODO

# IANA Considerations

TODO

# Acknowledgements
{: numbered="no"}

John Mattsson was nice enough to point out the need for this being documented.
