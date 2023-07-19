package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestEasy(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/easy",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	output := terraform.Output(t, terraformOptions, "config")
	config := "\"debug\": true\n\"node-label\":\n- \"foo=bar\"\n- \"something=amazing\"\n\"tls-san\":\n- \"foo.local\"\n\"write-kubeconfig-mode\": \"0644\"\n"

	assert.Equal(t, config, output)
}
