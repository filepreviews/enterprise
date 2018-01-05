# FilePreviews Enterprise

Terraform module for FilePreviews Enterprise on AWS.

## Usage

### main.tf

```
module "filepreviews" {
  source = "github.com/filepreviews/enterprise?ref=v0.0.1"

  aws_profile  = "YOUR_AWS_PROFILE_NAME"
  license_path = "~/license.fpe"
}
```

### Provision

```bash
$ terraform init
$ terraform apply
```

### Cleanup

```bash
$ terraform destroy
```