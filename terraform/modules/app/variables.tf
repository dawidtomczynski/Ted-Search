variable "vpc_id" {
  type    = string
}

variable "subnet_id" {
  type    = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "av_zone" {
  type    = string
  default = "eu-central-1a"
}

variable "ami" {
  type    = string
  default = "ami-0a729c061d31b98fa"
}

variable "name" {
  type    = string
  default = "dawid-ted"
}

variable "bootcamp" {
  type    = string
  default = "poland1"
}

variable "created_by" {
  type    = string
  default = "dawid"
}

variable "private_key" {
  type    = string
  default = "/home/ubuntu/dawid-aws.pem"
}
