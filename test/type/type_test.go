package type_test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTypetest(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/typetest",
	})

	defer terraform.DestroyContext(t, t.Context(), terraformOptions)
	terraform.InitAndApplyContext(t, t.Context(), terraformOptions)

	terraform.OutputContext(t, t.Context(), terraformOptions, "config")
}
