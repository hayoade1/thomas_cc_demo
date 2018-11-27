# Dynamic Credentials for Legacy and Cloud Native Applications with Vault

This repo demonstrates how you to leverage Vault APIs and tools such as EnvConsul / Consul-template to allow frictionless integration with applications and benefit from dynamic secrets.

This is an incredibly modified version of [thomashashi/thomas_cc_demo](https://github.com/thomashashi/thomas_cc_demo). If you are looking for a Consul Connect demo, please refer to [thomashashi/thomas_cc_demo](https://github.com/thomashashi/thomas_cc_demo)

This repo uses Terraform to deploy the following pieces of infrastructure:
First, a Consul cluster is deployed.  Then, a set of client nodes are deployed.  All client nodes have Consul running.
- There are four pieces of the application.  A mongo database to store records, a set of APIs called Product and Listing, and a web client that renders results.  All pieces communicate with one another using the built in Consul Connect proxies.
- A Vault server is deployed which will provide dynamic credentials for Mongo DB.

## Provisioning and Running the demo:
Currently this demo is implemented in AWS platform only. Please follow steps in [Running the Demo](aws/README.md)

## Architecture Diagram:
