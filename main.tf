locals {
  config = {
    debug                                = var.debug
    bind-address                         = var.bind-address
    advertise-address                    = var.advertise-address
    tls-san                              = var.tls-san
    data-dir                             = var.data-dir
    cluster-cidr                         = var.cluster-cidr
    service-cidr                         = var.service-cidr
    service-node-port-range              = var.service-node-port-range
    cluster-dns                          = var.cluster-dns
    cluster-domain                       = var.cluster-domain
    egress-selector-mode                 = var.egress-selector-mode
    servicelb-namespace                  = var.servicelb-namespace
    write-kubeconfig                     = var.write-kubeconfig
    write-kubeconfig-mode                = var.write-kubeconfig-mode
    token                                = var.token
    token-file                           = var.token-file
    agent-token                          = var.agent-token
    agent-token-file                     = var.agent-token-file
    server                               = var.server
    cluster-reset                        = var.cluster-reset
    cluster-reset-restore-path           = var.cluster-reset-restore-path
    kube-apiserver-arg                   = var.kube-apiserver-arg
    etcd-arg                             = var.etcd-arg
    kube-controller-manager-arg          = var.kube-controller-manager-arg
    kube-scheduler-arg                   = var.kube-scheduler-arg
    etcd-expose-metrics                  = var.etcd-expose-metrics
    etcd-disable-snapshots               = var.etcd-disable-snapshots
    etcd-snapshot-name                   = var.etcd-snapshot-name
    etcd-snapshot-schedule-cron          = var.etcd-snapshot-schedule-cron
    etcd-snapshot-retention              = var.etcd-snapshot-retention
    etcd-snapshot-dir                    = var.etcd-snapshot-dir
    etcd-snapshot-compress               = var.etcd-snapshot-compress
    etcd-s3                              = var.etcd-s3
    etcd-s3-endpoint                     = var.etcd-s3-endpoint
    etcd-s3-endpoint-ca                  = var.etcd-s3-endpoint-ca
    etcd-s3-skip-ssl-verify              = var.etcd-s3-skip-ssl-verify
    etcd-s3-access-key                   = var.etcd-s3-access-key
    etcd-s3-secret-key                   = var.etcd-s3-secret-key
    etcd-s3-bucket                       = var.etcd-s3-bucket
    etcd-s3-region                       = var.etcd-s3-region
    etcd-s3-folder                       = var.etcd-s3-folder
    etcd-s3-insecure                     = var.etcd-s3-insecure
    etcd-s3-timeout                      = var.etcd-s3-timeout
    disable                              = var.disable
    disable-scheduler                    = var.disable-scheduler
    disable-cloud-controller             = var.disable-cloud-controller
    disable-kube-proxy                   = var.disable-kube-proxy
    node-name                            = var.node-name
    with-node-id                         = var.with-node-id
    node-label                           = var.node-label
    node-taint                           = var.node-taint
    image-credential-provider-bin-dir    = var.image-credential-provider-bin-dir
    image-credential-provider-config     = var.image-credential-provider-config
    container-runtime-endpoint           = var.container-runtime-endpoint
    snapshotter                          = var.snapshotter
    private-registry                     = var.private-registry
    system-default-registry              = var.system-default-registry
    node-ip                              = var.node-ip
    node-external-ip                     = var.node-external-ip
    resolv-conf                          = var.resolv-conf
    kubelet-arg                          = var.kubelet-arg
    kube-proxy-arg                       = var.kube-proxy-arg
    protect-kernel-defaults              = var.protect-kernel-defaults
    enable-pprof                         = var.enable-pprof
    selinux                              = var.selinux
    lb-server-port                       = var.lb-server-port
    cni                                  = var.cni
    enable-servicelb                     = var.enable-servicelb
    kube-apiserver-image                 = var.kube-apiserver-image
    kube-controller-manager-image        = var.kube-controller-manager-image
    cloud-controller-manager-image       = var.cloud-controller-manager-image
    kube-proxy-image                     = var.kube-proxy-image
    kube-scheduler-image                 = var.kube-scheduler-image
    pause-image                          = var.pause-image
    runtime-image                        = var.runtime-image
    etcd-image                           = var.etcd-image
    kubelet-path                         = var.kubelet-path
    cloud-provider-name                  = var.cloud-provider-name
    cloud-provider-config                = var.cloud-provider-config
    profile                              = var.profile
    audit-policy-file                    = var.audit-policy-file
    pod-security-admission-config-file   = var.pod-security-admission-config-file
    control-plane-resource-requests      = var.control-plane-resource-requests
    control-plane-resource-limits        = var.control-plane-resource-limits
    control-plane-probe-configuration    = var.control-plane-probe-configuration
    kube-apiserver-extra-mount           = var.kube-apiserver-extra-mount
    kube-scheduler-extra-mount           = var.kube-scheduler-extra-mount
    kube-controller-manager-extra-mount  = var.kube-controller-manager-extra-mount
    kube-proxy-extra-mount               = var.kube-proxy-extra-mount
    etcd-extra-mount                     = var.etcd-extra-mount
    cloud-controller-manager-extra-mount = var.cloud-controller-manager-extra-mount
    kube-apiserver-extra-env             = var.kube-apiserver-extra-env
    kube-scheduler-extra-env             = var.kube-scheduler-extra-env
    kube-controller-manager-extra-env    = var.kube-controller-manager-extra-env
    kube-proxy-extra-env                 = var.kube-proxy-extra-env
    etcd-extra-env                       = var.etcd-extra-env
    cloud-controller-manager-extra-env   = var.cloud-controller-manager-extra-env
  }

  # variables excluded from config
  filtered_config = { for k, v in local.config : k => v if v != null }

  json_encoded_config = jsonencode(local.filtered_config)
  json_config_content = (chomp(local.json_encoded_config) != "{}" ? local.json_encoded_config : "")

  yaml_encoded_config = yamlencode(local.filtered_config)
  yaml_config_content = (chomp(local.yaml_encoded_config) != "{}" ? local.yaml_encoded_config : "")

  file_path = (var.local_file_path == "" ? abspath(path.root) : var.local_file_path)
  file_name = var.local_file_name
  file = {
    tostring(local.file_name) = (strcontains(local.file_name, "yaml") ? local.yaml_config_content : local.json_config_content)
  }
}

resource "null_resource" "write_config" {
  for_each = local.file
  triggers = {
    config_content = each.value,
  }
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      set -x
      install -d '${local.file_path}'
      cat << EOF > '${local.file_path}/${each.key}'
      ${each.value}
      EOF
      chmod 0600 '${local.file_path}/${each.key}'
    EOT
  }
}
