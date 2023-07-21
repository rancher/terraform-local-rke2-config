
resource "random_uuid" "token" {}

module "TestAdvanced" {
  source = "../../"

  debug                              = true
  server                             = "https://example.com"
  disable                            = ["rke2-ingress-nginx"]
  bind-address                       = "0.0.0.0"
  token                              = random_uuid.token.result
  write-kubeconfig-mode              = "0644"
  cni                                = ["multus,cilium"]
  profile                            = "cis-1.6"
  selinux                            = true
  protect-kernel-defaults            = true
  pod-security-admission-config-file = "/etc/rancher/rke2/base-pss.yaml"
  node-ip                            = ["10.42.0.100"]
  cluster-cidr                       = ["10.42.0.0/16", "2001:cafe:42:0::/56"]
  service-cidr                       = ["10.43.0.0/16", "2001:cafe:42:1::/112"]

  kubelet-arg = [
    "alsologtostderr=true",
    "feature-gates=MemoryManager=true",
    "kube-reserved=cpu=400m,memory=1Gi",
    "system-reserved=cpu=400m,memory=1Gi",
    "memory-manager-policy=Static",
    "reserved-memory=0:memory=2Gi",
    "port=10250",
  ]

  kube-apiserver-arg = [
    "tls-cipher-suites=TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
  ]

  etcd-snapshot-retention     = 18
  etcd-snapshot-schedule-cron = "*/3 * * * *" #every 3 minute
  private-registry            = "/etc/rancher/rke2/registries.yaml"
  cloud-provider-name         = "rancher-vsphere"
  cloud-provider-config       = "/home/rancher/vsphere.conf"
  enable-pprof                = true
  kube-proxy-arg              = ["proxy-mode=ipvs"]
  etcd-s3                     = true
  etcd-s3-bucket              = "your-bucket-name"
  etcd-s3-folder              = "snapshotrestore"
  etcd-s3-region              = "your-bucket-region"
  etcd-s3-endpoint            = "your-s3-endpoint.com"
  etcd-s3-access-key          = "YOUR-ACCESS-KEY"
  etcd-s3-secret-key          = "YOUR-SECRET-KEY"
}
