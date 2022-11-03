variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "credentials" {
  type        = list
  default     = ["/home/ubuntu/.aws/credentials"]
  sensitive   = true
}

variable "name" {
  type        = string
  default     = "dawid-ted"
}

variable "private_key" {
  type        = string
  default     = "/home/ubuntu/dawid-aws.pem"
}
