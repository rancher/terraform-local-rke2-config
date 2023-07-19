
# Variable types are all string to match cli flags,
#  but you can use the type that matches your use case and convert it to string
module "TestEasy" {
  source                = "../../"
  write-kubeconfig-mode = "0644"
  tls-san               = "foo.local"
  node-label = (join(",", [for k, v in {
    foo       = "bar",
    something = "amazing",
  } : format("%s=%s", k, v)]))
  # node-label = "foo=bar,something=amazing" also works
  debug = tostring(true)
}
