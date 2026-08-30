variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-pathnex-eks"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.36"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "worker_instance_types" {
  description = "EC2 instance types for Spot workers"
  type        = list(string)

  default = [
    "t3.medium",
    "t3a.medium",
    "m5.large",
    "m5a.large"
  ]
}

variable "desired_nodes" {
  description = "Desired worker nodes"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Minimum worker nodes"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Maximum worker nodes"
  type        = number
  default     = 2
}

variable "bastion_instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default = "bastion_ed25519"
}

variable "my_ip" {
  description = "Your public IP in CIDR notation"
  type        = string
  default = "0.0.0.0/0"
}