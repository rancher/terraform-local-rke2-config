locals {
  # convert variables to their Terraform types
  debug                                = (var.debug != "" ? tobool(var.debug) : null)
  bind-address                         = (var.bind-address != "" ? toset(split(",", var.bind-address)) : null)
  advertise-address                    = (var.advertise-address != "" ? toset(split(",", var.advertise-address)) : null)
  tls-san                              = (var.tls-san != "" ? toset(split(",", var.tls-san)) : null)
  data-dir                             = (var.data-dir != "" ? var.data-dir : null)
  cluster-cidr                         = (var.cluster-cidr != "" ? toset(split(",", var.cluster-cidr)) : null)
  service-cidr                         = (var.service-cidr != "" ? toset(split(",", var.service-cidr)) : null)
  service-node-port-range              = (var.service-node-port-range != "" ? var.service-node-port-range : null)
  cluster-dns                          = (var.cluster-dns != "" ? toset(split(",", var.cluster-dns)) : null)
  cluster-domain                       = (var.cluster-domain != "" ? var.cluster-domain : null)
  egress-selector-mode                 = (var.egress-selector-mode != "" ? var.egress-selector-mode : null)
  servicelb-namespace                  = (var.servicelb-namespace != "" ? var.servicelb-namespace : null)
  write-kubeconfig                     = (var.write-kubeconfig != "" ? var.write-kubeconfig : null)
  write-kubeconfig-mode                = (var.write-kubeconfig-mode != "" ? var.write-kubeconfig-mode : null)
  token                                = (var.token != "" ? var.token : null)
  token-file                           = (var.token-file != "" ? var.token-file : null)
  agent-token                          = (var.agent-token != "" ? var.agent-token : null)
  agent-token-file                     = (var.agent-token-file != "" ? var.agent-token-file : null)
  server                               = (var.server != "" ? var.server : null)
  cluster-reset                        = (var.cluster-reset != "" ? tobool(var.cluster-reset) : null)
  cluster-reset-restore-path           = (var.cluster-reset-restore-path != "" ? var.cluster-reset-restore-path : null)
  kube-apiserver-arg                   = (var.kube-apiserver-arg != "" ? { for a in split(",", var.kube-apiserver-arg) : element(split("=", a), 0) => element(split("=", a), 1) } : null)
  etcd-arg                             = (var.etcd-arg != "" ? { for a in split(",", var.etcd-arg) : element(split("=", a), 0) => element(split("=", a), 1) } : null)
  kube-controller-manager-arg          = (var.kube-controller-manager-arg != "" ? { for a in split(",", var.kube-controller-manager-arg) : element(split("=", a), 0) => element(split("=", a), 1) } : null)
  kube-scheduler-arg                   = (var.kube-scheduler-arg != "" ? { for a in split(",", var.kube-scheduler-arg) : element(split("=", a), 0) => element(split("=", a), 1) } : null)
  etcd-expose-metrics                  = (var.etcd-expose-metrics != "" ? tobool(var.etcd-expose-metrics) : null)
  etcd-disable-snapshots               = (var.etcd-disable-snapshots != "" ? tobool(var.etcd-disable-snapshots) : null)
  etcd-snapshot-name                   = (var.etcd-snapshot-name != "" ? var.etcd-snapshot-name : null)
  etcd-snapshot-schedule-cron          = (var.etcd-snapshot-schedule-cron != "" ? var.etcd-snapshot-schedule-cron : null)
  etcd-snapshot-retention              = (var.etcd-snapshot-retention != "" ? tonumber(var.etcd-snapshot-retention) : null)
  etcd-snapshot-dir                    = (var.etcd-snapshot-dir != "" ? var.etcd-snapshot-dir : null)
  etcd-snapshot-compress               = (var.etcd-snapshot-compress != "" ? tobool(var.etcd-snapshot-compress) : null)
  etcd-s3                              = (var.etcd-s3 != "" ? tobool(var.etcd-s3) : null)
  etcd-s3-endpoint                     = (var.etcd-s3-endpoint != "" ? var.etcd-s3-endpoint : null)
  etcd-s3-endpoint-ca                  = (var.etcd-s3-endpoint-ca != "" ? var.etcd-s3-endpoint-ca : null)
  etcd-s3-skip-ssl-verify              = (var.etcd-s3-skip-ssl-verify != "" ? tobool(var.etcd-s3-skip-ssl-verify) : null)
  etcd-s3-access-key                   = (var.etcd-s3-access-key != "" ? var.etcd-s3-access-key : null)
  etcd-s3-secret-key                   = (var.etcd-s3-secret-key != "" ? var.etcd-s3-secret-key : null)
  etcd-s3-bucket                       = (var.etcd-s3-bucket != "" ? var.etcd-s3-bucket : null)
  etcd-s3-region                       = (var.etcd-s3-region != "" ? var.etcd-s3-region : null)
  etcd-s3-folder                       = (var.etcd-s3-folder != "" ? var.etcd-s3-folder : null)
  etcd-s3-insecure                     = (var.etcd-s3-insecure != "" ? tobool(var.etcd-s3-insecure) : null)
  etcd-s3-timeout                      = (var.etcd-s3-timeout != "" ? var.etcd-s3-timeout : null)
  disable                              = (var.disable != "" ? toset(split(",", var.disable)) : null)
  disable-scheduler                    = (var.disable-scheduler != "" ? tobool(var.disable-scheduler) : null)
  disable-cloud-controller             = (var.disable-cloud-controller != "" ? tobool(var.disable-cloud-controller) : null)
  disable-kube-proxy                   = (var.disable-kube-proxy != "" ? tobool(var.disable-kube-proxy) : null)
  node-name                            = (var.node-name != "" ? var.node-name : null)
  with-node-id                         = (var.with-node-id != "" ? tobool(var.with-node-id) : null)
  node-label                           = (var.node-label != "" ? { for l in split(",", var.node-label) : element(split("=", l), 0) => element(split("=", l), 1) } : null)
  node-taint                           = (var.node-taint != "" ? { for t in split(",", var.node-taint) : element(split("=", t), 0) => element(split("=", t), 1) } : null)
  image-credential-provider-bin-dir    = (var.image-credential-provider-bin-dir != "" ? var.image-credential-provider-bin-dir : null)
  image-credential-provider-config     = (var.image-credential-provider-config != "" ? var.image-credential-provider-config : null)
  container-runtime-endpoint           = (var.container-runtime-endpoint != "" ? var.container-runtime-endpoint : null)
  snapshotter                          = (var.snapshotter != "" ? var.snapshotter : null)
  private-registry                     = (var.private-registry != "" ? var.private-registry : null)
  system-default-registry              = (var.system-default-registry != "" ? var.system-default-registry : null)
  node-ip                              = (var.node-ip != "" ? var.node-ip : null)
  node-external-ip                     = (var.node-external-ip != "" ? toset(split(",", var.node-external-ip)) : null)
  resolv-conf                          = (var.resolv-conf != "" ? var.resolv-conf : null)
  kubelet-arg                          = (var.kubelet-arg != "" ? { for a in split(",", var.kubelet-arg) : element(split("=", a), 0) => element(split("=", a), 1) } : null)
  kube-proxy-arg                       = (var.kube-proxy-arg != "" ? { for a in split(",", var.kube-proxy-arg) : element(split("=", a), 0) => element(split("=", a), 1) } : null)
  protect-kernel-defaults              = (var.protect-kernel-defaults != "" ? tobool(var.protect-kernel-defaults) : null)
  enable-pprof                         = (var.enable-pprof != "" ? tobool(var.enable-pprof) : null)
  selinux                              = (var.selinux != "" ? tobool(var.selinux) : null)
  lb-server-port                       = (var.lb-server-port != "" ? tonumber(var.lb-server-port) : null)
  cni                                  = (var.cni != "" ? toset(split(",", var.cni)) : null)
  enable-servicelb                     = (var.enable-servicelb != "" ? tobool(var.enable-servicelb) : null)
  kube-apiserver-image                 = (var.kube-apiserver-image != "" ? var.kube-apiserver-image : null)
  kube-controller-manager-image        = (var.kube-controller-manager-image != "" ? var.kube-controller-manager-image : null)
  cloud-controller-manager-image       = (var.cloud-controller-manager-image != "" ? var.cloud-controller-manager-image : null)
  kube-proxy-image                     = (var.kube-proxy-image != "" ? var.kube-proxy-image : null)
  kube-scheduler-image                 = (var.kube-scheduler-image != "" ? var.kube-scheduler-image : null)
  pause-image                          = (var.pause-image != "" ? var.pause-image : null)
  runtime-image                        = (var.runtime-image != "" ? var.runtime-image : null)
  etcd-image                           = (var.etcd-image != "" ? var.etcd-image : null)
  kubelet-path                         = (var.kubelet-path != "" ? var.kubelet-path : null)
  cloud-provider-name                  = (var.cloud-provider-name != "" ? var.cloud-provider-name : null)
  cloud-provider-config                = (var.cloud-provider-config != "" ? var.cloud-provider-config : null)
  profile                              = (var.profile != "" ? var.profile : null)
  audit-policy-file                    = (var.audit-policy-file != "" ? var.audit-policy-file : null)
  pod-security-admission-config-file   = (var.pod-security-admission-config-file != "" ? var.pod-security-admission-config-file : null)
  control-plane-resource-requests      = (var.control-plane-resource-requests != "" ? { for r in split(",", var.control-plane-resource-requests) : element(split("=", r), 0) => element(split("=", r), 1) } : null)
  control-plane-resource-limits        = (var.control-plane-resource-limits != "" ? { for l in split(",", var.control-plane-resource-limits) : element(split("=", l), 0) => element(split("=", l), 1) } : null)
  control-plane-probe-configuration    = (var.control-plane-probe-configuration != "" ? { for c in split(",", var.control-plane-probe-configuration) : element(split("=", c), 0) => element(split("=", c), 1) } : null)
  kube-apiserver-extra-mount           = (var.kube-apiserver-extra-mount != "" ? { for m in split(",", var.kube-apiserver-extra-mount) : element(split("=", m), 0) => element(split("=", m), 1) } : null)
  kube-scheduler-extra-mount           = (var.kube-scheduler-extra-mount != "" ? { for m in split(",", var.kube-scheduler-extra-mount) : element(split("=", m), 0) => element(split("=", m), 1) } : null)
  kube-controller-manager-extra-mount  = (var.kube-controller-manager-extra-mount != "" ? { for m in split(",", var.kube-controller-manager-extra-mount) : element(split("=", m), 0) => element(split("=", m), 1) } : null)
  kube-proxy-extra-mount               = (var.kube-proxy-extra-mount != "" ? { for m in split(",", var.kube-proxy-extra-mount) : element(split("=", m), 0) => element(split("=", m), 1) } : null)
  etcd-extra-mount                     = (var.etcd-extra-mount != "" ? { for m in split(",", var.etcd-extra-mount) : element(split("=", m), 0) => element(split("=", m), 1) } : null)
  cloud-controller-manager-extra-mount = (var.cloud-controller-manager-extra-mount != "" ? { for m in split(",", var.cloud-controller-manager-extra-mount) : element(split("=", m), 0) => element(split("=", m), 1) } : null)
  kube-apiserver-extra-env             = (var.kube-apiserver-extra-env != "" ? { for e in split(",", var.kube-apiserver-extra-env) : element(split("=", e), 0) => element(split("=", e), 1) } : null)
  kube-scheduler-extra-env             = (var.kube-scheduler-extra-env != "" ? { for e in split(",", var.kube-scheduler-extra-env) : element(split("=", e), 0) => element(split("=", e), 1) } : null)
  kube-controller-manager-extra-env    = (var.kube-controller-manager-extra-env != "" ? { for e in split(",", var.kube-controller-manager-extra-env) : element(split("=", e), 0) => element(split("=", e), 1) } : null)
  kube-proxy-extra-env                 = (var.kube-proxy-extra-env != "" ? { for e in split(",", var.kube-proxy-extra-env) : element(split("=", e), 0) => element(split("=", e), 1) } : null)
  etcd-extra-env                       = (var.etcd-extra-env != "" ? { for e in split(",", var.etcd-extra-env) : element(split("=", e), 0) => element(split("=", e), 1) } : null)
  cloud-controller-manager-extra-env   = (var.cloud-controller-manager-extra-env != "" ? { for e in split(",", var.cloud-controller-manager-extra-env) : element(split("=", e), 0) => element(split("=", e), 1) } : null)
  # put all the variables in a map
  config = {
    debug                                = local.debug
    bind-address                         = local.bind-address
    advertise-address                    = local.advertise-address
    tls-san                              = local.tls-san
    data-dir                             = local.data-dir
    cluster-cidr                         = local.cluster-cidr
    service-cidr                         = local.service-cidr
    service-node-port-range              = local.service-node-port-range
    cluster-dns                          = local.cluster-dns
    cluster-domain                       = local.cluster-domain
    egress-selector-mode                 = local.egress-selector-mode
    servicelb-namespace                  = local.servicelb-namespace
    write-kubeconfig                     = local.write-kubeconfig
    write-kubeconfig-mode                = local.write-kubeconfig-mode
    token                                = local.token
    token-file                           = local.token-file
    agent-token                          = local.agent-token
    agent-token-file                     = local.agent-token-file
    server                               = local.server
    cluster-reset                        = local.cluster-reset
    cluster-reset-restore-path           = local.cluster-reset-restore-path
    kube-apiserver-arg                   = local.kube-apiserver-arg
    etcd-arg                             = local.etcd-arg
    kube-controller-manager-arg          = local.kube-controller-manager-arg
    kube-scheduler-arg                   = local.kube-scheduler-arg
    etcd-expose-metrics                  = local.etcd-expose-metrics
    etcd-disable-snapshots               = local.etcd-disable-snapshots
    etcd-snapshot-name                   = local.etcd-snapshot-name
    etcd-snapshot-schedule-cron          = local.etcd-snapshot-schedule-cron
    etcd-snapshot-retention              = local.etcd-snapshot-retention
    etcd-snapshot-dir                    = local.etcd-snapshot-dir
    etcd-snapshot-compress               = local.etcd-snapshot-compress
    etcd-s3                              = local.etcd-s3
    etcd-s3-endpoint                     = local.etcd-s3-endpoint
    etcd-s3-endpoint-ca                  = local.etcd-s3-endpoint-ca
    etcd-s3-skip-ssl-verify              = local.etcd-s3-skip-ssl-verify
    etcd-s3-access-key                   = local.etcd-s3-access-key
    etcd-s3-secret-key                   = local.etcd-s3-secret-key
    etcd-s3-bucket                       = local.etcd-s3-bucket
    etcd-s3-region                       = local.etcd-s3-region
    etcd-s3-folder                       = local.etcd-s3-folder
    etcd-s3-insecure                     = local.etcd-s3-insecure
    etcd-s3-timeout                      = local.etcd-s3-timeout
    disable                              = local.disable
    disable-scheduler                    = local.disable-scheduler
    disable-cloud-controller             = local.disable-cloud-controller
    disable-kube-proxy                   = local.disable-kube-proxy
    node-name                            = local.node-name
    with-node-id                         = local.with-node-id
    node-label                           = local.node-label
    node-taint                           = local.node-taint
    image-credential-provider-bin-dir    = local.image-credential-provider-bin-dir
    image-credential-provider-config     = local.image-credential-provider-config
    container-runtime-endpoint           = local.container-runtime-endpoint
    snapshotter                          = local.snapshotter
    private-registry                     = local.private-registry
    system-default-registry              = local.system-default-registry
    node-ip                              = local.node-ip
    node-external-ip                     = local.node-external-ip
    resolv-conf                          = local.resolv-conf
    kubelet-arg                          = local.kubelet-arg
    kube-proxy-arg                       = local.kube-proxy-arg
    protect-kernel-defaults              = local.protect-kernel-defaults
    enable-pprof                         = local.enable-pprof
    selinux                              = local.selinux
    lb-server-port                       = local.lb-server-port
    cni                                  = local.cni
    enable-servicelb                     = local.enable-servicelb
    kube-apiserver-image                 = local.kube-apiserver-image
    kube-controller-manager-image        = local.kube-controller-manager-image
    cloud-controller-manager-image       = local.cloud-controller-manager-image
    kube-proxy-image                     = local.kube-proxy-image
    kube-scheduler-image                 = local.kube-scheduler-image
    pause-image                          = local.pause-image
    runtime-image                        = local.runtime-image
    etcd-image                           = local.etcd-image
    kubelet-path                         = local.kubelet-path
    cloud-provider-name                  = local.cloud-provider-name
    cloud-provider-config                = local.cloud-provider-config
    profile                              = local.profile
    audit-policy-file                    = local.audit-policy-file
    pod-security-admission-config-file   = local.pod-security-admission-config-file
    control-plane-resource-requests      = local.control-plane-resource-requests
    control-plane-resource-limits        = local.control-plane-resource-limits
    control-plane-probe-configuration    = local.control-plane-probe-configuration
    kube-apiserver-extra-mount           = local.kube-apiserver-extra-mount
    kube-scheduler-extra-mount           = local.kube-scheduler-extra-mount
    kube-controller-manager-extra-mount  = local.kube-controller-manager-extra-mount
    kube-proxy-extra-mount               = local.kube-proxy-extra-mount
    etcd-extra-mount                     = local.etcd-extra-mount
    cloud-controller-manager-extra-mount = local.cloud-controller-manager-extra-mount
    kube-apiserver-extra-env             = local.kube-apiserver-extra-env
    kube-scheduler-extra-env             = local.kube-scheduler-extra-env
    kube-controller-manager-extra-env    = local.kube-controller-manager-extra-env
    kube-proxy-extra-env                 = local.kube-proxy-extra-env
    etcd-extra-env                       = local.etcd-extra-env
    cloud-controller-manager-extra-env   = local.cloud-controller-manager-extra-env
  }
  filtered_config = { for k, v in local.config : k => v if v != null }
  config_content  = (chomp(yamlencode(local.filtered_config)) != "{}" ? chomp(yamlencode(local.filtered_config)) : "")
}

resource "local_file" "config" {
  content  = local.config_content
  filename = "rke2-config.yaml"
}
