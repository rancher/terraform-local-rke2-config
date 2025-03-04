package easy

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestEasy(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../../examples/easy",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	terraform.Output(t, terraformOptions, "config")
}
