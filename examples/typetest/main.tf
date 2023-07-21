# WARNING!! Don't use this example, this is just a data sample.
# This example exercises some of the text validation on the input variables to give some examples of what is expected.
# The values in this example are valid on their own, but may be non-sensical when combined.
# This example is not intended to be used as-is, but rather as a reference for the types of values that can be used.

resource "random_uuid" "token" {}

module "TestTypetest" {
  source = "../../"

  debug             = true
  bind-address      = "0.0.0.0"
  advertise-address = "10.1.1.100"
  tls-san = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "127.0.0.1",
    "::1",
    "localhost",
    "ip-10.1.1.100",
  ]
  data-dir                    = "/var/lib/rancher/rke2"
  cluster-cidr                = ["10.42.0.0/16"]
  service-cidr                = ["10.43.0.0/16"]
  service-node-port-range     = "30000-32767"
  cluster-dns                 = ["10.43.0.10"]
  cluster-domain              = "cluster.local"
  egress-selector-mode        = "agent"
  servicelb-namespace         = "kube-system"
  write-kubeconfig            = "/etc/rancher/rke2/rke2.yaml"
  write-kubeconfig-mode       = "0600"
  token                       = random_uuid.token.result
  token-file                  = "/var/lib/rancher/rke2/server/node-token"
  agent-token                 = random_uuid.token.result
  agent-token-file            = "/var/lib/rancher/rke2/agent/agent-token"
  server                      = "https://127.0.0.1:6443"
  cluster-reset               = false
  cluster-reset-restore-path  = "/var/lib/rancher/rke2/server/db/snapshots"
  kube-apiserver-arg          = ["tls-cipher-suites=TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"]
  etcd-arg                    = []
  kube-controller-manager-arg = []
  kube-scheduler-arg          = []
  etcd-expose-metrics         = false
  etcd-disable-snapshots      = false
  etcd-snapshot-name          = "etcd-snapshot"
  etcd-snapshot-schedule-cron = "0 */12 * * *"
  etcd-snapshot-retention     = 5
  etcd-snapshot-dir           = "/var/lib/rancher/rke2/server/db/snapshots"
  etcd-snapshot-compress      = false
  etcd-s3                     = true
  etcd-s3-endpoint            = "s3.amazonaws.com"
  etcd-s3-endpoint-ca         = "/etc/rancher/rke2/etcd-s3-endpoint-ca.crt"
  etcd-s3-skip-ssl-verify     = false
  etcd-s3-access-key          = "MY-AWS-ACCESS-KEY"
  etcd-s3-secret-key          = "MY-AWS-SECRET-KEY"
  etcd-s3-bucket              = "my-aws-bucket"
  etcd-s3-region              = "us-east-1"
  etcd-s3-folder              = "my-aws-folder"
  etcd-s3-insecure            = false
  etcd-s3-timeout             = "5m"
  disable                     = ["rke2-ingress-nginx"]
  disable-scheduler           = false
  disable-cloud-controller    = false
  disable-kube-proxy          = false
  node-name                   = "my-node-name"
  with-node-id                = false
  node-label = [
    "node.kubernetes.io/instance-type=t3.xl",
  ]
  node-taint = [
    "node.kubernetes.io/unschedulable=NoSchedule",
  ]
  image-credential-provider-bin-dir = "/usr/local/bin"
  image-credential-provider-config  = "/etc/rancher/rke2/credprovider-config.yaml"
  container-runtime-endpoint        = "unix:///run/rke2/containerd/containerd.sock"
  snapshotter                       = "native"
  private-registry                  = "/etc/rancher/rke2/priivateregistry-config.yaml"
  system-default-registry           = "docker.io"
  node-ip                           = ["::1"]
  node-external-ip                  = ["100.1.100.1"]
  resolv-conf                       = "/etc/resolv.conf"
  kubelet-arg = [
    "alsologtostderr=true",
    "feature-gates=MemoryManager=true",
    "kube-reserved=cpu=400m,memory=1Gi",
    "system-reserved=cpu=400m,memory=1Gi",
    "memory-manager-policy=Static",
    "reserved-memory=0:memory=2Gi",
    "port=10250",
  ]
  kube-proxy-arg                       = []
  protect-kernel-defaults              = false
  enable-pprof                         = false
  selinux                              = false
  lb-server-port                       = "8090"
  cni                                  = ["multus", "canal"]
  enable-servicelb                     = false
  kube-apiserver-image                 = "rancher/kube-apiserver"
  kube-controller-manager-image        = "rancher/kube-controller-manager:latest"
  cloud-controller-manager-image       = "private.registry.example/cloud-controller-manager:latest"
  kube-proxy-image                     = "private.registry.example:5000/kube-proxy:v1.18.6-rancher1"
  kube-scheduler-image                 = "https://private.registry.example:5000/kube-scheduler:v1.18.6-rancher1"
  pause-image                          = "pause"
  runtime-image                        = "runsc"
  etcd-image                           = "etcd"
  kubelet-path                         = "/var/lib/rancher/rke2/agent/bin/kubelet"
  cloud-provider-name                  = "aws"
  cloud-provider-config                = "/etc/rancher/rke2/cloud-config.yaml"
  profile                              = "cis-1.24"
  audit-policy-file                    = "/etc/rancher/rke2/audit-policy.yaml"
  pod-security-admission-config-file   = "/etc/rancher/rke2/pod-security-admission-config.yaml"
  control-plane-resource-requests      = ["cpu=100m,memory=250Mi"]
  control-plane-resource-limits        = ["cpu=200m,memory=500Mi"]
  control-plane-probe-configuration    = ["kube-proxy-startup-initial-delay-seconds=123"]
  kube-apiserver-extra-mount           = []
  kube-scheduler-extra-mount           = []
  kube-controller-manager-extra-mount  = []
  kube-proxy-extra-mount               = []
  etcd-extra-mount                     = []
  cloud-controller-manager-extra-mount = []
  kube-apiserver-extra-env             = []
  kube-scheduler-extra-env             = []
  kube-controller-manager-extra-env    = []
  kube-proxy-extra-env                 = []
  etcd-extra-env                       = []
  cloud-controller-manager-extra-env   = []
}
