# Dynamic Credentials for Legacy and Cloud Native Applications with Vault

This repo demonstrates how to leverage Vault APIs and tools such as EnvConsul and Consul-template to allow frictionless integration with applications and benefit from dynamic secrets.

Use-cases demonstrated:
- Consul: Service Configuration, Service Discovery
- Vault: Dynamic Credentials, AWS EC2 Authentication Method
- Terraform: Infrastructure-as-code

Time to complete: 30 minutes

This is an incredibly modified version of [thomashashi/thomas_cc_demo](https://github.com/thomashashi/thomas_cc_demo). If you are looking for a Consul Connect demo, please refer to [thomashashi/thomas_cc_demo](https://github.com/thomashashi/thomas_cc_demo)

## Architecture overview:
This repo uses Terraform to deploy the items:
- Infrastructure components:
  - First, a Consul cluster is deployed.  Then, a set of client nodes are deployed.  All client nodes have Consul running.
  - A Vault server is deployed which will provide dynamic credentials for Mongo DB. Vault will use Consul as its storage backend.
  - A Mongo DB server is deployed that will contain a Database called `bbthe90s`, and 2 Collections: `Products` and `Listing`. Each Collection will be pre-populated with some example records.
  - An AWS Elastic Load Balancer will be deployed that will allow an end user to access the application.

- Application components:
  - A Python [Web Client](https://github.com/kawsark/simple-client) that interacts with the end user, it queries Product and Listing API, then displays the contents on a web page.

  - A Python [Product API](https://github.com/kawsark/product-service)
    - Application configuration is read from `config.yml` and stored in Consul. [Consul Template](https://github.com/hashicorp/consul-template) is used render the application configuration file and managed application lifecycle.
    - Mongo DB credentials are obtained from Vault using [hvac Vault Python SDK](https://github.com/hvac/hvac). AWS EC2 Authentication is utilized to obtain a Vault token, then read from AWS dynamic secrets engine.

  - A Node.js [Listing API](https://github.com/kawsark/listing-service)
    - Application configuration key value pairs are stored in Consul, and read as Environment Variables. [Envconsul](https://github.com/hashicorp/envconsul) is used render environment variables and managed application lifecycle.
    - Mongo DB credentials are obtained from Vault by Envconsul. AWS EC2 Authentication is utilized to obtain a Vault token, then provided to EnvConsul to read from AWS dynamic secrets engine.

## Provisioning and Running the demo:
Currently this demo is implemented in AWS platform only. Please follow steps in [Running the Demo](terraform/aws/README.md)

## Architecture Diagram:
TODO: Add Vault to diagram
![Architecture diagram for Non-connect version](diagrams/Consul-demo-No-connect.png)
