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
  RATS-ARCH: I-D.ietf-rats-architecture

  SEMA-VER:
   target: https://semver.org
   title: Semantic Versioning 2.0.0
   author:
     -
       ins: T. Preston-Werner
       name: Tom Preston-Werner
   date: 2021

  PSA-CERTIFIED:
   target: https://www.psacertified.org
   title: PSA Certified
   date: 2021

--- abstract

PSA Endorsements comprise reference values, cryptographic key material and
certification status information that a Verifier needs in order to appraise
attestation Evidence produced by a PSA device.  This memo defines such PSA
Endorsements as a profile of the CoRIM data model.

--- middle

# Introduction

PSA Endorsements comprise reference values, cryptographic key material and
certification status information that a Verifier needs in order to appraise
attestation Evidence produced by a PSA device {{PSA-TOKEN}}.  This memo defines
such PSA Endorsements as a profile of the CoRIM data model [TBD-CoRIM-ref].

# Conventions and Definitions

{::boilerplate bcp14}

The reader is assumed to be familiar with the terms defined in Section 2.1 of
{{PSA-TOKEN}} and in Section 4 of {{RATS-ARCH}}.

# PSA Endorsements
{: #sec-psa-endorsements }

PSA Endorsements describe an attesting device in terms of the hardware and
firmware components that make up its PSA Root of Trust (RoT). This includes
the identification and expected state of the device as well as the
cryptographic key material needed to verify Evidence signed by the device's PSA
RoT. Additionally, PSA Endorsements can include information related to the
certification status of the attesting device.

There are three basic types of PSA Endorsements:

* Reference Values ({{sec-ref-values}}), i.e., measurements of the PSA RoT
  firmware;
* Attestation Verification Claims ({{sec-keys}}), i.e., cryptographic keys
  that can be used to verify signed Evidence produced by the PSA RoT, along
  with the identifiers that bind the keys to their device instances;
* Certification Claims ({{sec-certificates}}), i.e., metadata that describe
  the certification status associated with a PSA device.

A fourth category of PSA Endorsements is the:

* Endorsements Block List ({{sec-endorsements-block-list}), which is used to
  invalidate previously provisioned Endorsements.

## PSA Endorsements to PSA RoT Linkage
{: #sec-psa-rot-id}

Each PSA Endorsement - be it a Reference Value, Attestation Verification Claim
or Certification Claim - is associated with an immutable PSA RoT.  A PSA
Endorsement is associated to its PSA RoT by means of the unique PSA RoT
identifier known as Implementation ID (see Section 3.2.2 of {{PSA-TOKEN}}).
Besides, a PSA Endorsement can be associated with a specific instance of a
certain PSA RoT - as in the case of Attestation Verification Claims.  A PSA
Endorsement is associated with a PSA RoT instance by means of the Instance ID
(see Section 3.2.1 of {{PSA-TOKEN}}) and its "parent" Implementation ID.

These identifiers are typically found in the subject of a CoMID triple, encoded
in an `environment-map` as shown in {{ex-psa-rot-id}}.

~~~
{::include examples/psa-rot-identification.diag}
~~~
{: #ex-psa-rot-id title="Example PSA RoT Identification" }

## Reference Values
{: #sec-ref-values}

Reference Values carry measurements and other metadata associated with the
updatable firmware in a PSA RoT.  When appraising Evidence, the Verifier
compares Reference Values against the values found in the Software Components
of the PSA token (see Section 3.4.1 of {{PSA-TOKEN}}).

Each measurement is encoded in a `measurement-map` of a CoMID
`reference-triple-record`.  Since a `measurement-map` can encode one or more
measurements, a single `reference-triple-record` can carry as many measurements
as needed, provided they belong to the same PSA RoT carried in the subject of
the "reference value" triple.

The identifier of a measurement is encoded in a `psa-refval-id` object as
follows:

~~~
{::include psa-ext/refval-id.cddl}
~~~

The semantics of the codepoints in the `psa-refval-id` map are equivalent to
those in the `psa-software-component` map defined in Section 3.4.1 of
{{PSA-TOKEN}}.

In order to support PSA Reference Value identifiers, the
`$measured-element-type-choice` CoMID type is extended as follows:

~~~
{::include psa-ext/refval-id-ext.cddl}
~~~

and automatically bound to the `comid.mkey` in the `measurement-map`.

The raw measurement is encoded in a `digests-type` object in the
`measurements-value-map`.  The `digests-type` array MUST contain only one
entry.  If multiple digests of the same measured component exist (obtained with
different hash algorithms), a different `psa.measurement-desc` MUST be used in
the identifier.

The example in {{ex-reference-value}} shows the PSA Endorsement of type
Reference Value for a firmware measurement associated with Implementation ID
`acme-implementation-id-000000001`.

~~~
{::include examples/ref-value.diag}
~~~
{: #ex-reference-value title="Example Reference Value"}

## Attestation Verification Claims
{: #sec-keys}

An Attestation Verification Claim carries the verification key associated with
the Initial Attestation Key (IAK) of a PSA device.  When appraising Evidence,
the Verifier uses the Implementation ID and Instance ID claims (see
{{sec-psa-rot-id}}) to retrieve the verification key that it must use to check
the signature on the Evidence.  This allows the Verifier to prove (or disprove)
the Attester's claimed identity.

Each verification key is provided alongside the corresponding device Instance
and Implementation IDs in an `attest-key-triple-record`.  Specifically:

* The Instance and Implementation IDs are encoded in the environment-map as
  shown in {{ex-psa-rot-id}};
* The IAK public key is carried in the `comid.key` entry in the
  `verification-key-map`.  The IAK public key is encoded as a COSE_Key
  according to Section 7 of {{!RFC8152}}. There MUST be only one
  `verification-key-map` in an `identity-triple-record`;
* The optional `comid.keychain` entry MUST NOT be set by a producer and MUST be
  ignored by a consumer.

The example in {{ex-attestation-verification-claim}} shows the PSA Endorsement
of type Attestation Verification Claim carrying a secp256r1 EC public IAK
associated with Instance ID `4ca3...d296`.

~~~
{::include examples/instance-pub.diag}
~~~
{: #ex-attestation-verification-claim title="Example Attestation Verification Claim"}

## Certification Claims
{: #sec-certificates}

PSA Certified {{PSA-CERTIFIED}} defines a certification scheme for the PSA
ecosystem.  A product - either a hardware component, a software component, or
an entire device - that is verified to meet the security criteria established
by the PSA Certified scheme is warranted a PSA Certified Security Assurance
Certificate (SAC).  A SAC contains information about the certification of a
certain product (e.g., the target system, the attained certification level, the
test lab that conducted the evaluation, etc.), and has a unique Certificate
Number.

The linkage between a PSA RoT and a related SAC is provided by a Certification
Claim, which binds the PSA RoT Implementation ID with the SAC unique
Certificate Number.  When appraising Evidence, the Verifier can use the
Certification Claims associated with the identified Attester as ancillary input
to the Appraisal Policy, or to enrich the produced Attestation Result.

A Certification Claim is encoded in an `psa-cert-triple-record`, which extends
the `$$triples-map-extension` socket, as follows:

~~~
{::include psa-ext/cert-triple.cddl}
~~~

* The Implementation ID to which the SAC applies is encoded in the
  `tagged-impl-id-type`;
* The unique SAC Certificate Number is encoded in the `psa-cert-num-type`.

A single CoMID can carry one or more Certification Claims.

The example in {{ex-certification-claim}} shows a Certification Claim for
Certificate Number `1234567890123 - 12345` and Implementation ID
`acme-implementation-id-000000001`.

~~~
{::include examples/cert-val.diag}
~~~
{: #ex-certification-claim title="Example Certification Claim with `supplement` Link-Relation"}

## Endorsements Block List
{: #sec-endorsements-block-list}

The following three "blocklist" claims:

* `reference-blocklist-triple`
* `attest-key-blocklist-triple`
* `cert-blocklist-triple`

are defined with the same syntax but opposite semantics with regards to their
"positive" counterparts to allow removing previously provisioned endorsements
from the acceptable set.

# Security Considerations

TODO

# IANA Considerations

TODO

# Acknowledgements
{: numbered="no"}

TODO
