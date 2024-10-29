# Define the provider
provider "azurerm" {
  features {}

  # Azure details
  subscription_id = "56ac1107-64d9-439a-9c99-dd90aa2f458e"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "debtSolverRG"
  location = "East US"
}

# az login --use-device-code