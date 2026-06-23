package advanced

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAdvanced(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/advanced",
	})

	defer terraform.DestroyContext(t, t.Context(), terraformOptions)
	terraform.InitAndApplyContext(t, t.Context(), terraformOptions)

	terraform.OutputContext(t, t.Context(), terraformOptions, "config")
}
