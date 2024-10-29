# Define the provider
provider "azurerm" {
  features {}

  # Azure details
  subscription_id = "replace"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "debtSolverRG"
  location = "East US"
}

# az login --use-device-code