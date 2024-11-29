terraform {
  backend "azurerm" {
    resource_group_name  = "debtSolverTfRG"
    storage_account_name = "debtsolvertfsa"
    container_name       = "debtsolvertfcontainer"
    key                  = "terraform.tfstate"
  }
}
