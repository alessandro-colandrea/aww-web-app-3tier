variable "vpc_id" {
    type = string
}
variable "app_subnet_cidrs" {
  type = list(string)
}

variable "priv_subnet_ids" { type = list(string) }
variable "db_user" { type = string }
variable "db_password" { type = string }
variable "db_name" { type = string }

