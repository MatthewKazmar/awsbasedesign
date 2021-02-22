variable "region" { default = "us-east-1" }
variable "ami_id" { default =  "ami-02642c139a9dfb378" }
variable "vpcs" {
  default = {
    prod = {
      name = "prod_VPC"
      cidr = "10.100.0.0/22"
      av_zone = "us-east-1a"
    }
    dev = {
      name = "dev_VPC"
      cidr = "10.100.8.0/22"
      av_zone = "us-east-1b"
    }
    qa = {
      name = "qa_vpc"
      cidr = "10.100.16.0/22"
      av_zone = "us-east-1c"
    }
    mgmt = {
      name = "mgmt_vpc"
      cidr = "10.100.24.0/22"
      av_zone = "us-east-1f"
    }
  }
}
variable "my_asn" { default = 64605 }
variable "my_public_ip" { default = "" }

