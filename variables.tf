variable "aws_profile" {
  description = "This declares the AWS credentials profile to use."
  type        = "string"
  default     = "default"
}

variable "cidr" {
  description = "The CIDR block to provision for the VPC, if set to something other than the default, both internal_subnets and external_subnets have to be defined as well."
  default     = "10.30.0.0/16"
}

variable "internal_subnets" {
  description = "A list of CIDRs for internal subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones."
  default     = ["10.30.0.0/19", "10.30.64.0/19", "10.30.128.0/19"]
}

variable "external_subnets" {
  description = "A list of CIDRs for external subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones."
  default     = ["10.30.32.0/20", "10.30.96.0/20", "10.30.160.0/20"]
}

variable "availability_zones" {
  description = "A comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both internal_subnets and external_subnets have to be defined as well."
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "name" {
  description = "The cluster name"
}

variable "license_path" {
  description = "Path to FilePreviews license file"
}
