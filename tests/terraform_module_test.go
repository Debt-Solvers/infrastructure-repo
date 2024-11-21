package tests

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformDeployment(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../", // Path to your Terraform configuration
        Vars: map[string]interface{}{
            "resource_group_name": "test-rg",
            "location":            "East US",
            "vnet_name":           "test-vnet",
        },
    }

    defer terraform.Destroy(t, terraformOptions)

    // Apply Terraform
    terraform.InitAndApply(t, terraformOptions)

    // Validate Resource Group
    rgName := terraform.Output(t, terraformOptions, "resource_group_name")
    assert.Equal(t, "test-rg", rgName)

    // Validate NSG Rule for SSH
    nsgRules := terraform.OutputList(t, terraformOptions, "nsg_rules")
    assert.Contains(t, nsgRules, "AllowSSH")

    // Validate Public IP DNS
    publicIP := terraform.Output(t, terraformOptions, "public_ip")
    assert.Contains(t, publicIP, "caa900debtsolverapp")
}
