provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

variable "subscription_id" {
  description = "The Azure Subscription ID to use."
  type        = string
}

# Azure Resource Group
resource "azurerm_resource_group" "aks_dev" {
  name     = "rg-roger-k8s-dev"
  location = var.location
  tags = var.tags
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_dev" {
  name                = "aks-roger-k8s-dev"
  location            = azurerm_resource_group.aks_dev.location
  resource_group_name = azurerm_resource_group.aks_dev.name
  dns_prefix          = "roger-k8s-dev"
  kubernetes_version  = "1.33"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true
  
  tags = var.tags
}
