variable "environment" {
  description = "Entornos de despliegue (dev, qa, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "cidrblock para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Zonas de disponibilidad"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}