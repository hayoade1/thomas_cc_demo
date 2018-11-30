# Running the Demo

- The packer configuration used to build the machine images is in the `packer` directory. All images except the one built with Vault Enterprise are currently public.
- Use `make aws` if you want to build the AWS AMIs; if building your own packer images, please edit the AWS Account # appropriately.

## Architecture overview

This terraform code will spin up a simple three-tier web application _without_ Consul Connect. Please view the main [README](../../README.md) for an Architecture overview.

For reference, the three tiers are:

 1. A web frontend `web_client`, written in Python, which calls...
 2. Two internal apis (a `listing` service written in Node, and a `product` service written in Python), both of which store data in ...
 3. A MongoDB instance

 A Vault instance is also instantiated to provide Dynamic credentials for MongoDB.

Services find each other using the [Service Discovery](https://www.consul.io/discovery.html) mechanism in Consul.
.

The code which built all of the images is in the `packer` directory located at the top level of this repo. While you shouldn't have to build the images which are used in this demo, the Packer code is there to enable you to do so, and also to allow you to see how the application configuration changes as you move your infrastructure to Consul Connect.

## Requirements

You will need:
 1. A machine with git and ssh installed
 2. The appropriate [Terraform binary](https://www.terraform.io/downloads.html) for your system
 3. An AWS account with credentials which allow you to deploy infrastructure
 4. An already-existing [Amazon EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
    - *NOTE*: if the EC2 Key Pair you specify is not your default ssh key, you will need to use `ssh -i /path/to/private_key` instead
      of `ssh` in the commands below

### Terminal Setup

 1. Open a terminal window and please run the commands:
    ```
    export AWS_ACCESS_KEY_ID="<your access key ID>"
    export AWS_SECRET_ACCESS_KEY="<your secret key>"
    export AWS_DEFAULT_REGION="us-east-1"
    ```
    Replace `<your access key ID>` with your AWS Access Key ID and `<your secret key>` with your AWS Secret Access Key (see [Access Keys (Access Key ID and Secret Access Key)](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for more help). *NOTE*: Currently, the Packer-built AMIs are only in `us-east-1`.

 2. Please run: `git clone https://github.com/kawsark/thomas_cc_demo.git`

## Deployment

 1. `cd thomas_cc_demo/terraform/aws/`
 2. `cp terraform.auto.tfvars.example terraform.auto.tfvars`
 3. Edit the `terraform.auto.tfvars` file:
    1. Change the `project_name` to something which is 1) only all lowercase letters, numbers and dashes; 2) is unique to you; 3) and ends in `-noconnect`
    2. In the `hashi_tags` line change `owner` to be your email address.
    3. Change `ssh_key_name` to the name of the key identified in "Requirement 4"

    The combination of `project_name` and `owner` **must be unique within your AWS organization** --- they are used to set the Consul cluster membership when those instances start up
 4. Save your changes to the `terraform.auto.tfvars` file
 5. `terraform init`
 6. When you see "Terraform has been successfully initialized!" ...
 7. Run `terraform plan -out tf.plan`
 8. When you see
    ```
    This plan was saved to: tf.plan

    To perform exactly these actions, run the following command to apply:
        terraform apply "tf.plan"
    ```
    ...
 9. Run `terraform apply tf.plan`

This will take a couple minutes to run. Once the command prompt returns, wait a couple minutes and the demo will be ready.

### Show the web frontend

 1. `terraform output webclient-lb`
 2. Point a web browser at the value returned

### Service Discovery

 1. `terraform output webclient_servers`
 2. `ssh ubuntu@<first ip returned>`
    1. When asked `Are you sure you want to continue connecting (yes/no)?` answer `yes` and hit enter
 3. `cat /lib/systemd/system/web_client.service`
    1. The line `Environment=LISTING_URI=http://listing.service.consul:8000` tells `web_client` how to talk to the `listing` service
    2. The line `Environment=PRODUCT_URI=http://product.service.consul:5000` tells `web_client` how to talk to the `product` service
    3. Note how both are using Consul for service discovery

 5. Switch to the web browser and reload the page a few times
 6. Return to the terminal and look at the data going back and forth across the network. See how it's in plaintext.
 7. Hit _Cntl-C_ to exit tcpdump
 8. Re-iterate that while services are finding each other dynamically, nothing is protecting their traffic
 9. `cat /etc/consul/web_client.hcl` --- show a routine Consul service definition file, there's some health checks, but very routine

 ### Service Configuration
Pending

 ### Dynamic Credentials
Pending
