resource "random_uuid" "token" {}

module "TestTypetest" {
  source = "../../"

  # This example exercises the validation for every variable in the module.
  # The values are valid on their own, but may be non-sensical when combined.
  # This is not intended to be used as-is, but as a reference for expected value types.

  # General & Logging
  debug                   = "true"
  server                  = "https://192.168.1.10:6443"
  data-dir                = "/var/lib/rancher/rke2-typetest"
  token                   = random_uuid.token.result
  agent-token             = "uvwxyz.9876543210zyxwvu"
  write-kubeconfig-mode   = "0640"
  write-kubeconfig-group  = "staff"
  profile                 = "cis-1.23"
  selinux                 = "true"
  protect-kernel-defaults = "true"
  enable-pprof            = "true"

  # Networking
  bind-address                = "0.0.0.0"
  advertise-address           = "192.168.1.10"
  tls-san                     = ["my-cluster.example.com", "192.168.1.11"]
  tls-san-security            = "true"
  cni                         = ["multus", "cilium"]
  cluster-cidr                = ["10.42.0.0/16", "2001:cafe:42:0::/56"]
  service-cidr                = ["10.43.0.0/16", "2001:cafe:42:1::/112"]
  service-node-port-range     = "30000-32767"
  cluster-dns                 = ["10.43.0.10"]
  cluster-domain              = "cluster.local"
  node-ip                     = ["192.168.1.10"]
  node-external-ip            = ["203.0.113.5"]
  resolv-conf                 = "/etc/resolv.conf"
  egress-selector-mode        = "cluster"
  ingress-controller          = "traefik"
  node-external-dns           = ["8.8.8.8", "1.1.1.1"]
  node-internal-dns           = ["10.10.10.10"]
  lb-server-port              = "9345"
  servicelb-namespace         = "rke2-servicelb"
  write-kubeconfig            = "/tmp/rke2.yaml"
  token-file                  = "/var/lib/rancher/rke2/server/token"
  agent-token-file            = "/var/lib/rancher/rke2/server/agent-token"
  secrets-encryption-provider = "secretbox"

  # Component Args
  kubelet-arg                       = ["--v=2", "--serialize-image-pulls=false"]
  kube-proxy-arg                    = ["--v=2", "--proxy-mode=ipvs"]
  kube-apiserver-arg                = ["--v=2", "--allow-privileged=true"]
  kube-controller-manager-arg       = ["--v=2"]
  kube-scheduler-arg                = ["--v=2"]
  kube-cloud-controller-manager-arg = ["--v=2"]
  etcd-arg                          = ["--log-level=debug"]

  # Etcd & Datastore
  datastore-endpoint               = "etcd://10.0.1.5:2379,etcd://10.0.1.6:2379"
  datastore-cafile                 = "/path/to/db-ca.pem"
  datastore-certfile               = "/path/to/db-cert.pem"
  datastore-keyfile                = "/path/to/db-key.pem"
  etcd-disable-snapshots           = "false"
  etcd-expose-metrics              = "true"
  etcd-snapshot-name               = "rke2-etcd-snapshot"
  etcd-snapshot-retention          = "10"
  etcd-snapshot-schedule-cron      = "0 */5 * * *"
  etcd-snapshot-dir                = "/var/lib/rancher/rke2/server/db/snapshots"
  etcd-snapshot-compress           = "true"
  etcd-snapshot-reconcile-interval = "15m"
  etcd-s3                          = "true"
  etcd-s3-bucket                   = "rke2-etcd-snapshots"
  etcd-s3-endpoint                 = "s3.us-west-2.amazonaws.com"
  etcd-s3-endpoint-ca              = "/path/to/s3-ca.pem"
  etcd-s3-folder                   = "rke2-backups"
  etcd-s3-insecure                 = "false"
  etcd-s3-region                   = "us-west-2"
  etcd-s3-skip-ssl-verify          = "false"
  etcd-s3-timeout                  = "10m"
  etcd-s3-access-key               = "EXAMPLE_ACCESS_KEY"
  etcd-s3-secret-key               = "EXAMPLE_SECRET_KEY"
  etcd-s3-session-token            = "EXAMPLE_SESSION_TOKEN"
  etcd-s3-bucket-lookup-type       = "path"
  etcd-s3-config-secret            = "my-s3-secret"
  etcd-s3-proxy                    = "http://proxy.example.com:8080"
  etcd-s3-retention                = "20"

  # Cluster Reset
  cluster-reset              = "true"
  cluster-reset-restore-path = "/var/lib/rancher/rke2/server/db/snapshots/snapshot-to-restore"

  # Disabled Components
  disable                  = ["rke2-coredns"]
  disable-scheduler        = "false"
  disable-cloud-controller = "false"
  disable-kube-proxy       = "false"

  # Node Configuration
  node-name                              = "my-rke2-node-1"
  with-node-id                           = "true"
  node-label                             = ["app=testing", "tier=frontend"]
  node-taint                             = ["CriticalAddonsOnly=true:NoExecute"]
  node-name-from-cloud-provider-metadata = "false"

  # Runtime & Images
  container-runtime-endpoint        = "unix:///var/run/containerd/containerd.sock"
  snapshotter                       = "overlayfs"
  private-registry                  = "/etc/rancher/rke2/registries.yaml"
  system-default-registry           = "my-registry.corp.net"
  default-runtime                   = "runc"
  disable-default-registry-endpoint = "false"
  nonroot-devices                   = "false"
  image-credential-provider-bin-dir = "/var/lib/rancher/credentialprovider/bin"
  image-credential-provider-config  = "/var/lib/rancher/credentialprovider/config.yaml"
  kube-apiserver-image              = "my-registry.com/rancher/kube-apiserver:v1.2.3"
  kube-controller-manager-image     = "my-registry.com/rancher/kube-controller-manager:v1.2.3"
  cloud-controller-manager-image    = "my-registry.com/rancher/cloud-controller-manager:v1.2.3"
  kube-proxy-image                  = "my-registry.com/rancher/kube-proxy:v1.2.3"
  kube-scheduler-image              = "my-registry.com/rancher/kube-scheduler:v1.2.3"
  pause-image                       = "my-registry.com/rancher/pause:3.1"
  runtime-image                     = "my-registry.com/rancher/runtime:v1.2.3"
  etcd-image                        = "my-registry.com/rancher/etcd:v3.4.5"
  helm-job-image                    = "my-registry.com/rancher/helm-job:v1.2.3"

  # Experimental
  kubelet-path       = "/usr/local/bin/alt-kubelet"
  supervisor-metrics = "true"
  embedded-registry  = "true"

  # Cloud Provider
  cloud-provider-name   = "aws"
  cloud-provider-config = "/etc/rancher/rke2/cloud.conf"

  # Security
  audit-policy-file                  = "/etc/rancher/rke2/audit.yaml"
  pod-security-admission-config-file = "/etc/rancher/rke2/psa.yaml"

  # Static Pod Configuration
  control-plane-resource-requests      = ["cpu=100m", "memory=256Mi"]
  control-plane-resource-limits        = ["cpu=200m", "memory=512Mi"]
  control-plane-probe-configuration    = ["liveness:initialDelaySeconds=15"]
  kube-apiserver-extra-mount           = ["/host/path/api:/container/path/api"]
  kube-scheduler-extra-mount           = ["/host/path/scheduler:/container/path/scheduler"]
  kube-controller-manager-extra-mount  = ["/host/path/cm:/container/path/cm"]
  kube-proxy-extra-mount               = ["/host/path/proxy:/container/path/proxy"]
  etcd-extra-mount                     = ["/host/path/etcd:/container/path/etcd"]
  cloud-controller-manager-extra-mount = ["/host/path/ccm:/container/path/ccm"]
  kube-apiserver-extra-env             = ["KEY_API=VALUE_API"]
  kube-scheduler-extra-env             = ["KEY_SCHED=VALUE_SCHED"]
  kube-controller-manager-extra-env    = ["KEY_CM=VALUE_CM"]
  kube-proxy-extra-env                 = ["KEY_PROXY=VALUE_PROXY"]
  etcd-extra-env                       = ["KEY_ETCD=VALUE_ETCD"]
  cloud-controller-manager-extra-env   = ["KEY_CCM=VALUE_CCM"]

  # Module-specific variables (not part of RKE2 config)
  local_file_path = abspath(path.root)
  local_file_name = "rke2-config.yaml"
}
