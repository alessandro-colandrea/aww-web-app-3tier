variable "instance_type" {
    type=string
}

variable "ami" {
    type=string
}

variable "vpc_id" {
    type=string
}

variable "region" {
    type =string
}

variable "db_user" { 
    type = string 
}

variable "db_name" { 
    type = string 
}

variable "db_host" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "alb_sg_id" {
    type = string
}