module "TestEasy" {
  source                = "../../"
  write-kubeconfig-mode = "0644"
  tls-san               = ["foo.local"]
  node-label = [
    "foo=bar",
    "something=amazing",
  ]
  debug = tostring(true)
}
