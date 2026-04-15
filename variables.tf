variable "region" {
  type = string
}
variable "vpc_cidr" {
    type=string
}
variable "subnet_pubb" {
    type=string
}

variable "subnet_pubb2" {
    type=string
  
}
variable "instance_type" {
    type=string
}

variable "ami" {
    type=string
}

variable "subnet_priv" {
    type=string
}

variable "subnet_priv2"{
    type=string
}
variable "db_user" { 
    type = string 
}
variable "db_password" {
     type = string 
      sensitive = true 
} # sensitive nasconde la pass nei log
variable "db_name" { 
    type = string 
}
