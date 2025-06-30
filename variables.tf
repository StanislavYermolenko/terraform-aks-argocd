variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "my-aks-rg"
}

variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  default     = "East US"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "my-aks-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "myaks"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "The size of the Virtual Machines in the node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "aks-vnet"
}

variable "subnet_name" {
  description = "The name of the subnet for AKS"
  type        = string
  default     = "aks-subnet"
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "subnet_address_prefixes" {
  description = "The address prefixes for the AKS subnet"
  type        = list(string)
  default     = ["10.240.0.0/16"]
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
}