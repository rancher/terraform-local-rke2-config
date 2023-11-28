# Terraform Local RKE2 Config

This module uses the yamlencode and jsonencode Terraform functions to provide config contents from the variables supplied.
There are two different outputs on this module, yaml and json. Either may be used to configure rke2.
This is an "Independent" module, please see [terraform.md](./terraform.md) for more information.

## Examples

### Local State

The specific use case for the example modules is temporary infrastructure for testing purposes.
With that in mind, it is not expected that we manage the resources as a team, therefore the state files are all stored locally.
If you would like to store the state files remotely, add a terraform backend file (`*.name.tfbackend`) to your implementation module.
https://www.terraform.io/language/settings/backends/configuration#file

## Development and Testing

### Paradigms and Expectations

Please make sure to read [terraform.md](./terraform.md) to understand the paradigms and expectations that this module has for development.

### Environment

It is important to us that all collaborators have the ability to develop in similar environments, so we use tools which enable this as much as possible.
These tools are not necessary, but they can make it much simpler to collaborate.

* I use [nix](https://nixos.org/) that I have installed using [their recommended script](https://nixos.org/download.html#nix-install-macos)
* I use [direnv](https://direnv.net/) that I have installed using brew.
* I simply use `direnv allow` to enter the environment
* I navigate to the `tests` directory and run `go test -v -timeout=5m -parallel=10`
* To run an individual test I nvaigate to the `tests` directory and run `go test -v -timeout=5m -run <test function name>`
  * eg. `go test -v -timeout=5m -run TestBasic`
* I use `override.tf` files to change the values of `examples` to personalized data so that I can run them

Our continuous integration tests in the GitHub [ubuntu-latest runner](https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2204-Readme.md), which has many different things installed.

### RKE2 Binary

When developing, we build `variables.tf` based on the help command on the RKE2 binary.
This is a big topic, please see [variables.md](./variables.md) for more information.

### Override Tests

You may want to test this code with slightly different parameters for your environment.
Check out [Terraform override files](https://developer.hashicorp.com/terraform/language/files/override) as a clean way to modify the inputs without accidentally committing any personalized code.
