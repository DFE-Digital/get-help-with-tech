# Get Help With Technology Secrets Management

**Author:** robert.hettrick@digital.education.gov.uk

**Date:** 14th July 2021

**Status:** Draft


## Purpose

This document is explore the way secrets are kept and maintained within the Get Help With Technology (GHWT) service.

## Organisation-wide secret management

There is no general purpose secrets management applicable everywhere in the Department for Education (DfE).

The closest answer is probably to use [Azure Key Vault](https://docs.google.com/document/d/1LdV62LhE9V6Li0hG5FwzILZF9UTY-09DmHFP4nEF8W4/edit), but this is primarily aimed at automation rather than intra-team secure credential sharing. Additionally GHWT currently doesn't use any of the Azure estate, so this appears incongruous.

Another solution used in the wider DfE for secrets sharing is [One Time Secret](https://onetimesecret.com/). However this is primarily for a single use password share, rather than for long term multiple secret sharing.

The result of this is that an understanding of how GHWT currently handles secrets is needed along with an assessment of it's fitness for purpose.

## As-is GHWT secrets management

The service currently stores secrets in multiples places, namely:

* Environment Variables
* Repository Secrets

### Environment Variables

The following environment variables are in use for secrets and configuration:

* ComputaCenter - API credentials
    + GHWT__COMPUTACENTER__OUTGOING_API__PASSWORD
    + GHWT__COMPUTACENTER__OUTGOING_API__USERNAME
* Google Analytics - Tracking identifier
    + GHWT__GOOGLE__ANALYTICS__TRACKING_ID
* Gov.UK Notify - API key
    + GHWT__GOVUK_NOTIFY__API_KEY
* Sentry - DSN for alerts
    + GHWT__SENTRY__DSN
* Slack - Credentials and config
    + GHWT__SLACK__EVENT_NOTIFICATIONS__CHANNEL
    + GHWT__SLACK__EVENT_NOTIFICATIONS__USERNAME
    + GHWT__SLACK__EVENT_NOTIFICATIONS__WEBHOOK_URL
    + GHWT__SLACK__NOTIFICATIONS_CHANNEL__WEBHOOK_URL
* Support Performance Access Token
    + GHWT__SUPPORT__PERFORMANCE_DATA_ACCESS_TOKEN
* ZenDesk - Credentials
    + GHWT__ZENDESK__TOKEN
    + GHWT__ZENDESK__USERNAME

Importantly all of the above are retrievable by logging into a host in an environment.

### Repository Secrets

The [GitHub Repo](https://github.com/DFE-Digital/get-help-with-tech) stores a couple of secrets to allow GitHub actions to build and deploy code to the environments. These secrets are:

* CloudFoundry - Credentials for Gov.UK PaaS
    + CF_USER
    + CF_PASSWORD
* Docker - Credentials for Docker
    + DOCKER_USERNAME
    + DOCKER_PASSWORD

As detailed in the [GitHub Documentation](https://docs.github.com/en/actions/reference/encrypted-secrets) there is no clear way to retrieve existing secrets.

The author is reaching out to Digital Tools Support and the previous service TA to try and retrieve this information. If not possible, then a rotation (since updating is possible) is suggested during this period of service closure.

Note: it can be inferred from the Gov.UK PaaS event logs that the CF_USER = get-help-with-tech-ci-dev@digital.education.gov.uk

## Note 20 July 2021
Secrets for CF_USER, DOCKER_USERNAME, DOCKER_PASSWORD were forwarded to the tech team. If needed, the CF_PASSWORD will require password reset via the Tech Group Service portal at some point in the future.