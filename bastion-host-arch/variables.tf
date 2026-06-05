variable "vpc_cidr" {
    type = string
}

variable "public_subnet_cidr" {
    type = string
}

variable "private_subnet_cidr" {
    type = string
}

variable "public_subnet_zone" {
    type = string
}

variable "private_subnet_zone" {
    type = string
}

variable "instance_type" {
    type    = string
    default = "t3.micro"
}

variable "public_key_path" {
    type = string
}