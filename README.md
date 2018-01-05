# FilePreviews Enterprise

Terraform module for FilePreviews Enterprise on AWS.

## What is Terraform?

> Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.

Read more about Terraform: https://www.terraform.io

## Getting started

Go to https://enterprise.filepreviews.io/trial/ to get a 30-day free trial of the FilePreviews Enterprise beta.

### Install Terraform

Go to https://www.terraform.io/downloads.html for the available downloads for the latest version of Terraform. Please download the proper package for your operating system and architecture.

### main.tf

```
module "filepreviews" {
  source = "github.com/filepreviews/enterprise?ref=v1.4.0"

  aws_profile  = "YOUR_AWS_PROFILE_NAME"
  license_key = "YOUR_FILEPREVIEWS_ENTERPRISE_LICENSE_KEY"
}
```

In `aws_profile`, specify the profile to use from your AWS shared credentials file. The default location for this file is `$HOME/.aws/credentials` on Linux and OS X, or `"%USERPROFILE%\.aws\credentials"` for Windows users.

In `license_key`, specify the key provided to you for your FilePreviews Enterprise installation.

### Provision

Provisioning will create every resource required to run FilePreviews Enterprise on a new VPC. Currently only the `us-east-1` region is supported.

- 1 Application Load Balancer
- 1 m5.large EC2 instance
- 1 c5.large EC2 instance
- 1 db.t2.small RDS instance
- 1 SQS queue
- 1 VPC
- 2 Subnets
- 1 NAT Gateway

```bash
$ terraform init
$ terraform apply
```

### Cleanup

This will completely destroy the Terraform-managed infrastructure.

```bash
$ terraform destroy
```
