
variable "region" {
  description="The region in which to build the resources"
  type=string
  default="ca-central-1"
}

variable "profile" {
  description="The profile under which the resources should be created. This profile should exist in the credentials file for AWS"
  type=string
  default="ahcterraform"
}

variable "instance_ami" {
  description="The ami to use when creating the ec2 instance"
  type=string
  default="ami-01b60a3259250381b"
}

variable "instance_type" {
  description="The instance type to use when creating the ec2 instance"
  type=string
  default="t2.micro"
}

variable max_scalable_instances {
   type=number
   description="The maximum number of scalable instances"
   default=4
}
variable min_scalable_instances {
   type=number
   description="The maximum number of scalable instances"
   default=2
}
variable "resource_name" {
  description="The organization name of the resource"
  type=string
  default="scalableec2"
}

variable "server_port" {
  description="The port upon which the http server will listen"
  type=number
  default=8080
}
variable "elb_port" {
  description="The port upon which the elastic loadbalancer will listen"
  type=number
  default=80
}

variable "org_owner" {
  description="The organization owner of the resources"
  type=string
  default="ngraham"
}

