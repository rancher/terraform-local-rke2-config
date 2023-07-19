# Variables

The interface for this terrform module is a mixture of generated content and manual elaboration.

## The Creation Process

Creating the `variables.tf` first requires that you download the latest rke2 binary for your system.
Then run the `helptojson.sh` script in the root of the repository, it assumes that the proper rke2 bin version is in your path as `rke2`
Redirect the output of the script to variables.tf (or a different file if you want to compare changes) `./helptojson.sh > variables.tf` .
Then take a look at the new file and compare the changes from the previous version, validate that the information is correct and copy elaborated data into the new version.
If any new variables were added make sure that their descriptions make sense and provide a good verbose description for our users.

## The RKE2 Binary

We are not producing multiple versions of this module, and in general our deprecation policy on arguments allows us to be fairly confident of backwards compatibility.
This creates a source of error though, the version of the RKE2 binary that we use to generate the variables should always be from the latest release.
This makes sure that all of the latest additions to the options are available, while the deprecation policy should enable backwards compatibility for those who generated earlier.
All variables have defaults, so if the user does not change the default, they should not need to regenerate their config.
This module is optional to help users generate a config file, it is not required for installing RKE2.
The user may supply a config file in the same directory as their other files, or may pass their config file to the install module,
or may accept no config to get all of the default options.

## Help To Json Script

This takes the help command from the rke2 binary and uses `bash specific syntax` along with `awk (gnu)`, `sed (gnu)`, `echo `, `jq `, and `read`.
The assumption is that the person building the variables.tf is using the Nix environment, but if the versions of the dependencies are the same then that is fine.

Steps "The script":

1. identifies the variables as lines starting with double dash
2. identifies the description from the variable name by separating with the first parenthesis `(`

   1. assumes that all descriptions will start with the category of the variable in parenthesis
   2. eg. `--thing-to-change value (category) description of thing to change [env variable]`
      1. the description is `(category) description of thing to change [env variable]`
3. strips out the beginning dashes from the variable, converting a cli option from `--thing-to-change` to `thing-to-change`.

   1. assumes that there is only long form variables (double dash) and no short form (single dash)
4. removes any leading and trailing whitespace from the variable and description
5. splits the variable name into two parts, a name and a type

   1. assumes there are only two types: boolean and string
   2. assumes that all variables expecting a string have a trailing "value"
      1. eg. `--thing-to-change value` is a string
      2. eg. `--thing-to-change` is a boolean
6. removes any environment variable indicators

   1. assumes environment variable information is the only thing in brackets
      1. if any other info is in brackets, it will remove it
   2. eg. `(category) description of thing to change [env variable]` becomes `(category) description of thing to change`
7. adds a period to the end of the description and capitalizes the first letter

   1. this is to pass the variable linting that Terraform does before publishing to the registry
   2. eg. `(category) description of thing to change` becomes `(Category) description of thing to change.`
8. processes this data into json and arranges it into Terraform style variable format

## Manual Inspection

There are generally two parts to the manual inspection of the variables.

1. Is the description a valid sentence and does it make gramatical sense
2. Is the description clear enough?
   1. Does it explain the option well enough for the user to make an educated decision?
      1. we try to guide less advanced users away from options which make it harder for us to support
         1. this means that our descriptions are precise, but not necessarily verbose
      2. we need to be clear about how to use the variable, but not how to use rke2 with that variable
         1. this includes variable type, defaults, and how and when to send in more than one value
         2. it would be nice to have some idea of options that are coupled, like the s3 options
      3. many of the types and other info can only be gathered from the source code
         1. The cli arguments are copied from k3s, here is the k3s source code
            1. https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go
            2. make sure to change the version to the latest supported release/tag version
         2. Not all arguments are copied directly from k3s, this source code specified what is brought over and/or changed
            1. https://github.com/rancher/rke2/blob/v1.27.3%2Brke2r1/pkg/cli/cmds/server.go
            2. make sure to change the version to the latest supported release/tag version
            3. `copyFlag` means that the option is available in rke2 copied from k3s
            4. `dropFlag` means that the option isn't available in rke2
            5. `hideFlag` means that the option is available, but users should not change it
            6. there is also the option to overwrite the option, watch out for these
            7. be aware that the help cli and the source are not in the same order
   2. if more information is necessary, is there a link to the documentation where they can learn more?
   3. if there is no documentation, please add a link in the comments describing where the information came from

## Validation

Once the descriptions are in place, we need to get validations in place to allow a seemless "specify it only if you need to" experience.
This means that every variable should default to "" but validate to reinforce types which will be necessary for generating the yaml.


The config file is read by urfavcli into cli arguments, and since cli arguments have no type validation (they are all strings), it makes sense for this module to do the same.
This means that if a variable is left in the default state (an empty string), we ignore it.
If a variable is specified, we validate it as best we can so that we can convert it properly to yaml.
