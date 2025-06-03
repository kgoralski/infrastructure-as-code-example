variable "base_name" {
  type        = string
  description = "The base name of resources"
  default     = "mycompany"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "vpc_secondary_cidr" {
  type        = list(string)
  description = "The secondary CIDR block for the VPC. Pods will be allocated IP from this CIDR"
  default     = ["10.1.0.0/16", "10.2.0.0/16", "10.3.0.0/16"]
}

variable "azs" {
  type        = list(string)
  description = "The list of vpc az"
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "public_subnets" {
  type        = list(string)
  description = "The list of public subnet"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "The list of private subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "The list of database subnet"
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = true
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(any)
  default     = {}
}

variable "eip_count" {
  description = "Additional tags for the public subnets"
  default     = 3
}

variable "tags" {
  type        = map(string)
  description = "The default map of tags"
}
