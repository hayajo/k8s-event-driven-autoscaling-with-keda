variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the cluster security group will be provisioned"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
}

variable "namespace" {
  type        = string
  description = "Namespace for the project. e.g. \"myproject\""
}
