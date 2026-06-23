package easy

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestEasy(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/easy",
	})

	defer terraform.DestroyContext(t, t.Context(), terraformOptions)
	terraform.InitAndApplyContext(t, t.Context(), terraformOptions)

	terraform.OutputContext(t, t.Context(), terraformOptions, "config")
}
