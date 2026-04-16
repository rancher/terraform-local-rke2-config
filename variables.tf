# Validations in this file are not exhaustive, but meant to validate input types and formats.
# All variables should have a default value of "" (empty string) to indicate that the user wants to use the default RKE2 value.
# This means that all variables are optional, and the user can choose to override any value.
# When a user overrides a value, we use the validation block to ensure that the value is of the correct type and format.


# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/root.go#L14
# Default: https://github.com/golang/go/blob/master/src/sync/atomic/type.go#L35
variable "debug" {
  type        = string
  description = <<-EOT
    (Logging) If true, turn on debug logs.
    Defaults to the Go default of false.
  EOT
  default     = null
  validation {
    condition = (
      var.debug != null ? can(regex("^(true|false)$", var.debug)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L111
# Type override: https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/server.go#L49
# Default: https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/server.go#L15
variable "data-dir" {
  type        = string
  description = <<-EOT
    (Data) The folder to hold state.
    Defaults to "/var/lib/rancher/rke2".
  EOT
  default     = null
  validation {
    condition = (
      var.data-dir != null ? can(regex("^/(?:[\\w\\-\\.]+[/]?)+$", var.data-dir)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L178
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/daemons/control/server.go#L104
variable "bind-address" {
  type        = string
  description = <<-EOT
    (Listener) The IPv4/IPv6 address for the RKE2 server to bind to.
    Defaults to '0.0.0.0'.
  EOT
  default     = null
  validation {
    condition = (
      var.bind-address != null ? anytrue([
        can(regex("^(?:[[:digit:]]{1,3}\\.){3}[[:digit:]]{1,3}$", var.bind-address)),          # IPv4
        can(regex("^(?:[[:xdigit:]]{0,4}\\:{1,7}){1,7}[[:xdigit:]]{0,4}$", var.bind-address)), # IPv6
      ]) : true
    )
    error_message = "If an address is specified, it must be an IPv4 or IPv6 address with lower case letters."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L189
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/cli/server/server.go#L241
variable "advertise-address" {
  type        = string
  description = <<-EOT
    (Listener) The IPv4/IPv6 address that the apiserver uses to advertise to members of the cluster.
    Defaults to the node's external-ip or internal-ip.
  EOT
  default     = null
  validation {
    condition = (
      var.advertise-address != null ? anytrue([
        can(regex("^(?:[[:digit:]]{1,3}\\.){3}[[:digit:]]{1,3}$", var.advertise-address)),        # IPv4
        can(regex("^(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4}$", var.advertise-address)), # IPv6
      ]) : true
    )
    error_message = "If an address is specified, it must be a valid IPv4 or IPv6 address."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L199
# Defaults(kubernetes): https://github.com/k3s-io/k3s/blob/main/pkg/daemons/control/deps/deps.go#L429
# Defaults(localhost): https://github.com/k3s-io/k3s/blob/main/pkg/cli/server/server.go#L267
# Defaults(hostname): https://github.com/k3s-io/k3s/blob/main/pkg/util/net.go#L162
variable "tls-san" {
  type        = list(string)
  description = <<-EOT
    (Listener) A list of additional hostnames or IPv4/IPv6 addresses to add as Subject Alternative Names (SANs) on the server's TLS certificate.
    See Kubernetes documentation for default values.
    https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/
  EOT
  default     = null
  validation {
    condition = (
      var.tls-san != null ? can(concat(var.tls-san, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  validation {
    condition = (
      var.tls-san != null ? alltrue(
        [for s in var.tls-san : anytrue([
          can(regex("^[[:alpha:]](?:[[:alnum:]\\p{Pd}]{1,62}\\.)*[[:alnum:]\\p{Pd}]{1,62}[[:alnum:]](?::[[:digit:]]{1,5})?$", s)), # FQDN with optional port
          can(regex("^(?:[[:digit:]]{1,3}\\.){3}[[:digit:]]{1,3}(?::[[:digit:]]{1,5})?$", s)),                                     # IPv4 with optional port
          can(regex("^(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4}$", s)),                                                    # IPv6
        ])]
      ) : true
    )
    error_message = "If specified, value must be a list of valid hostnames, IPv4, or IPv6 addresses with lower case letters."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L235
variable "tls-san-security" {
  type        = string
  description = <<-EOT
    (Listener) If true, refuse to add Subject Alternative Names to the server's TLS certificate 
    that are not associated with the Kubernetes API Server, server nodes, or values from the 'tls-san' option.
    Defaults to true.
  EOT
  default     = null
  validation {
    condition = (
      var.tls-san-security != null ? can(regex("^(true|false)$", var.tls-san-security)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L122
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/daemons/control/server.go#L223
variable "cluster-cidr" {
  type        = list(string)
  description = <<-EOT
    (Networking) A list of IPv4/IPv6 network CIDRs to use for pod IPs.
    Defaults to "10.42.0.0/16".
  EOT
  default     = null
  validation {
    condition = (
      var.cluster-cidr != null ? can(concat(var.cluster-cidr, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  validation {
    condition = (
      var.cluster-cidr != null ? alltrue(
        [for c in var.cluster-cidr : can(cidrhost(c, 1))]
      ) : true
    )
    error_message = "If specified, value must be a list of valid CIDRs."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L127
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/daemons/control/server.go#L228
variable "service-cidr" {
  type        = list(string)
  description = <<-EOT
    (Networking) A list of IPv4/IPv6 network CIDRs to use for service IPs.
    Defaults to "10.43.0.0/16".
  EOT
  default     = null
  validation {
    condition = (
      var.service-cidr != null ? can(concat(var.service-cidr, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  validation {
    condition = (
      var.service-cidr != null ? alltrue([
        for c in var.service-cidr : can(cidrhost(c, 1))
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid CIDRs."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L132
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L136
variable "service-node-port-range" {
  type        = string
  description = <<-EOT
    (Networking) The port range to reserve for services with NodePort visibility.
    Defaults to "30000-32767".
  EOT
  default     = null
  validation {
    condition = (
      var.service-node-port-range != null ? can(regex("[[:digit:]]{1,5}\\-[[:digit:]]{1,5}", var.service-node-port-range)) : true
    )
    error_message = "If specified, value must be a valid range."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L138
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/daemons/control/server.go#L233
variable "cluster-dns" {
  type        = list(string)
  description = <<-EOT
    (Networking) The IPv4 Cluster IP for the coredns service.
    This should be an address within your 'service-cidr' range.
    Defaults to "10.43.0.10".
  EOT
  default     = null
  validation {
    condition = (
      var.cluster-dns != null ? can(concat(var.cluster-dns, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  validation {
    condition = (
      var.cluster-dns != null ? alltrue([
        for c in var.cluster-dns : anytrue([
          can(regex("^(?:[[:digit:]]{1,3}\\.){3}[[:digit:]]{1,3}$", c)),        # IPv4
          can(regex("^(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4}$", c)), # IPv6
        ])
      ]) : true
    )
    error_message = "If specified, value must be a list of valid IPv4 or IPv6 addresses."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L143
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L147
variable "cluster-domain" {
  type        = string
  description = <<-EOT
    (Networking) The top-level domain for the cluster.
    Defaults to "cluster.local".
  EOT
  default     = null
  validation {
    condition = (
      var.cluster-domain != null ? anytrue([
        can(regex("^[[:alpha:]](?:[[:alnum:]\\p{Pd}]{1,62}\\.)+[[:alnum:]\\p{Pd}]{1,62}[[:alnum:]](?::[[:digit:]]{1,5})?$", var.cluster-domain)) # hostname with optional port
    ]) : true)
    error_message = "If specified, value must be a hostname."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L232
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L235
variable "egress-selector-mode" {
  type        = string
  description = <<-EOT
    (Networking) The egress selector mode.
    Must be one of 'agent', 'cluster', 'pod', or 'disabled'.
    Defaults to 'agent'.
  EOT
  default     = null
  validation {
    condition = (
      var.egress-selector-mode != null ? can(regex("^(agent|cluster|pod|disabled)$", var.egress-selector-mode)) : true
    )
    error_message = "If specified, value must be one of 'agent', 'cluster', 'pod', or 'disabled'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L238
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L241
variable "servicelb-namespace" {
  type        = string
  description = <<-EOT
    (Networking) The namespace where the ServiceLB component pods will be deployed.
    Defaults to 'kube-system'.
  EOT
  default     = null
  validation {
    condition = (
      var.servicelb-namespace != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.servicelb-namespace)) : true
    )
    error_message = "If specified, value must be an RFC-1123 namespace."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L243
# Default(directory): https://github.com/k3s-io/k3s/blob/main/pkg/datadir/datadir.go#L16
# Default(path): https://github.com/k3s-io/k3s/blob/main/pkg/server/server.go#L435
variable "write-kubeconfig" {
  type        = string
  description = <<-EOT
    (Client) The file path where the kubeconfig for the admin client will be written.
    Defaults to '/etc/rancher/rke2/rke2.yaml'.
  EOT
  default     = null
  validation {
    condition = (
      var.write-kubeconfig != null ? can(regex("^/(?:[\\w\\-\\.]+[/]?)+$", var.write-kubeconfig)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L249
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/server/server.go#L468
variable "write-kubeconfig-mode" {
  type        = string
  description = <<-EOT
    (Client) The file mode (in octal) for the generated kubeconfig file.
    Defaults to '0600'.
  EOT
  default     = null
  validation {
    condition = (
      var.write-kubeconfig-mode != null ? can(regex("^(?:0[0-7]{3})$", var.write-kubeconfig-mode)) : true
    )
    error_message = "If specified, value must be a valid octal for file mode, such as '0600' or '0755'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L116
# Default(call to generate): https://github.com/k3s-io/k3s/blob/main/pkg/kubeadm/token.go#L45
# Default(generate): https://github.com/kubernetes/cluster-bootstrap/blob/master/token/util/helpers.go#L45
variable "token" {
  type        = string
  description = <<-EOT
    (Cluster) Shared secret used to join a server or agent to a cluster.
    If no token or token file is set, a random token is generated.
    The token must be in the format '[a-z0-9]{6}.[a-z0-9]{16}'.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L256
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/cluster/storage.go#L125
variable "token-file" {
  type        = string
  description = <<-EOT
    (Cluster) The path to a file containing the shared secret token.
    This is ignored if 'token' is set.
    If neither is set, a random token is generated.
    Defaults to "/var/lib/rancher/rke2/server/token".
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L262
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/cluster/bootstrap.go#L440
variable "agent-token" {
  type        = string
  description = <<-EOT
    (Cluster) A shared secret used exclusively for joining agents to the cluster (not servers).
    If not set, it defaults to the value of 'token'.
    The token must be in the format '[a-z0-9]{6}.[a-z0-9]{16}'.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L268
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/server/server.go#L396
variable "agent-token-file" {
  type        = string
  description = <<-EOT
    (Cluster) The path to a file containing the agent-specific token.
    This is ignored if 'agent-token' is set. Defaults to "/var/lib/rancher/rke2/server/agent-token".
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L274
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/cli/server/server.go#L115
# Default(loopback): https://github.com/k3s-io/k3s/blob/main/pkg/daemons/config/types.go#L258
variable "server" {
  type        = string
  description = <<-EOT
    (Cluster) The URL of the server to connect to when joining a cluster.
    Defaults to "https://127.0.0.1:6443" if not otherwise set.
  EOT
  default     = null
  validation {
    condition = (
      var.server != null ? anytrue([
        can(regex("^https?://(?:[[:alnum:]\\p{Pd}]{1,63}\\.)*[[:alnum:]\\p{Pd}]{1,63}(?::[[:digit:]]{1,5})?$", var.server)),                 # FQDN with optional port
        can(regex("^https?://(?:[[:digit:]]{1,3}\\.){3}[[:digit:]]{1,3}(?::[[:digit:]]{1,5})?$", var.server)),                               # IPv4 with optional port
        can(regex("^https?://[\\[]{0,1}(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4}[\\]]{0,1}[:]{0,1}[[:xdigit:]]{0,4}$", var.server)), # IPv6 with optional port
    ]) : true)
    error_message = "If specified, value must be an address starting with 'http(s)'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L286
# Default: https://github.com/golang/go/blob/master/src/sync/atomic/type.go#L35
variable "cluster-reset" {
  type        = string
  description = <<-EOT
    (Cluster) If true, forget all peers and become the sole member of a new cluster.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.cluster-reset != null ? can(regex("^(true|false)$", var.cluster-reset)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L292
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/etcd/etcd.go#L270
# Default(snapshot dir): https://github.com/k3s-io/k3s/blob/main/pkg/etcd/etcd.go#L1184
variable "cluster-reset-restore-path" {
  type        = string
  description = <<-EOT
    (Db) The path to a snapshot file to restore when 'cluster-reset' is true.
    The default snapshot path is "/var/lib/rancher/rke2/server/db/snapshots".
  EOT
  default     = null
  validation {
    condition = (
      var.cluster-reset-restore-path != null ? can(regex(
        "^/(?:[\\w\\.\\p{Pd}]+[/]?)+$",
        var.cluster-reset-restore-path
      )) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L149
# Default: https://github.com/k3s-io/k3s/blob/main/pkg/daemons/control/server.go#L153
variable "kube-apiserver-arg" {
  type        = list(string)
  description = <<-EOT
    (Flags) A list of additional arguments to pass to the kube-apiserver process.
    e.g., ["--v=4"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-apiserver-arg != null ? can(concat(var.kube-apiserver-arg, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L154
variable "etcd-arg" {
  type        = list(string)
  description = <<-EOT
    (Flags) A list of additional arguments to pass to the etcd process.
    e.g., ["--log-level=debug"].
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-arg != null ? can(concat(var.etcd-arg, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://etcd.io/docs/v3.2/op-guide/configuration/
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L164
variable "kube-controller-manager-arg" {
  type        = list(string)
  description = <<-EOT
    (Flags) A list of additional arguments to pass to the kube-controller-manager process.
    e.g., ["--v=4"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-controller-manager-arg != null ? can(concat(var.kube-controller-manager-arg, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L159
variable "kube-scheduler-arg" {
  type        = list(string)
  description = <<-EOT
    (Flags) A list of additional arguments to pass to the kube-scheduler process.
    e.g., ["--v=4"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-scheduler-arg != null ? can(concat(var.kube-scheduler-arg, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L330
variable "etcd-expose-metrics" {
  type        = string
  description = <<-EOT
    (Db) If true, expose etcd metrics on the client interface.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-expose-metrics != null ? can(regex("^(true|false)$", var.etcd-expose-metrics)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L335
variable "etcd-disable-snapshots" {
  type        = string
  description = <<-EOT
    (Db) If true, disable automatic etcd snapshots.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-disable-snapshots != null ? can(regex("^(true|false)$", var.etcd-disable-snapshots)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L340
variable "etcd-snapshot-name" {
  type        = string
  description = <<-EOT
    (Db) The base name for etcd snapshots.
    Defaults to 'etcd-snapshot'.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-snapshot-name != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.etcd-snapshot-name)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L346
variable "etcd-snapshot-schedule-cron" {
  type        = string
  description = <<-EOT
    (Db) A cron expression specifying the interval for etcd snapshots (e.g., '0 */5 * * *' for every 5 hours).
    Defaults to '0 */12 * * *'.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-snapshot-schedule-cron != null ? can(regex(
        "^((\\*(\\/\\d+)?|,|[0-5]?[[:digit:]](-[0-5]?[[:digit:]])?(,[0-5]?[[:digit:]](-[0-5]?[[:digit:]])?)*)\\s){4}((\\*(\\/\\d+)?|,|[0-7](-[0-7])?(,[0-7](-[0-7])?)*))$",
        var.etcd-snapshot-schedule-cron
      )) : true
    )
    error_message = "If specified, value must be a valid cron expression."
  }
}

# Type(int): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L352
variable "etcd-snapshot-retention" {
  type        = string
  description = <<-EOT
    (Db) The number of local etcd snapshots to retain.
    Defaults to 5.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-snapshot-retention != null ? can(regex("^[[:digit:]]+$", var.etcd-snapshot-retention)) : true
    )
    error_message = "If specified, value must be a number."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L358
variable "etcd-snapshot-dir" {
  type        = string
  description = <<-EOT
    (Db) The directory where local etcd snapshots are saved.
    Defaults to the 'db/snapshots' subdirectory of the data-dir.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-snapshot-dir != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.etcd-snapshot-dir)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L363
variable "etcd-snapshot-compress" {
  type        = string
  description = <<-EOT
    (Db) If true, compress etcd snapshots.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-snapshot-compress != null ? can(regex("^(true|false)$", var.etcd-snapshot-compress)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L368
variable "etcd-s3" {
  type        = string
  description = <<-EOT
    (Db) If true, enable backing up etcd snapshots to an S3-compatible object store.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3 != null ? can(regex("^(true|false)$", var.etcd-s3)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L373
variable "etcd-s3-endpoint" {
  type        = string
  description = <<-EOT
    (Db) The S3 endpoint URL for etcd snapshot backups.
    Defaults to 's3.amazonaws.com'.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-endpoint != null ? can(regex(
        "^(?:https?://)?[[:alpha:]](?:[[:alnum:]\\p{Pd}]{1,63}\\.)+[[:alnum:]\\p{Pd}]{1,62}[[:alnum:]](?::[[:digit:]]{1,5})?$",
        var.etcd-s3-endpoint
      )) : true
    )
    error_message = "If specified, value must be a fully qualified domain name."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L379
variable "etcd-s3-endpoint-ca" {
  type        = string
  description = <<-EOT
    (Db) The path to a custom CA certificate file for verifying the S3 endpoint's TLS certificate.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-endpoint-ca != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.etcd-s3-endpoint-ca)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L384
variable "etcd-s3-skip-ssl-verify" {
  type        = string
  description = <<-EOT
    (Db) If true, disable SSL certificate validation for the S3 endpoint.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-skip-ssl-verify != null ? can(regex("^(true|false)$", var.etcd-s3-skip-ssl-verify)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L389
variable "etcd-s3-access-key" {
  type        = string
  description = <<-EOT
    (Db) The S3 access key ID for authentication.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L395
variable "etcd-s3-secret-key" {
  type        = string
  description = <<-EOT
    (Db) The S3 secret access key for authentication.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L401
variable "etcd-s3-bucket" {
  type        = string
  description = <<-EOT
    (Db) The name of the S3 bucket to use for snapshot backups.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-bucket != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.etcd-s3-bucket)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L406
variable "etcd-s3-region" {
  type        = string
  description = <<-EOT
    (Db) The S3 region or bucket location.
    Defaults to 'us-east-1'.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-region != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.etcd-s3-region)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L412
variable "etcd-s3-folder" {
  type        = string
  description = <<-EOT
    (Db) The folder within the S3 bucket to store snapshots.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-folder != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.etcd-s3-folder)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L417
variable "etcd-s3-insecure" {
  type        = string
  description = <<-EOT
    (Db) If true, disable using HTTPS for S3 connections.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-insecure != null ? can(regex("^(true|false)$", var.etcd-s3-insecure)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(duration): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L422
variable "etcd-s3-timeout" {
  type        = string
  description = <<-EOT
    (Db) The timeout for S3 operations, specified as a Go duration string (e.g., '5m').
    Defaults to '5m0s'.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-timeout != null ? can(regex("^[\\d]+[smh]$", var.etcd-s3-timeout)) : true
    )
    error_message = "If specified, value must be a string duration ([\\d]+[smh])."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L433
variable "disable" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of packaged components to disable (e.g., 'rke2-coredns').
    Disabling a component prevents it from being deployed.
  EOT
  default     = null
  validation {
    condition = (
      var.disable != null ? can(concat(var.disable, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  validation {
    condition = (
      var.disable != null ? alltrue([
        for c in var.disable : can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", c))
      ]) : true
    )
    error_message = "If specified, value must be a list of RFC-1123 label names."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L437
variable "disable-scheduler" {
  type        = string
  description = <<-EOT
    (Components) If true, disable the default Kubernetes scheduler.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.disable-scheduler != null ? can(regex("^(true|false)$", var.disable-scheduler)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L442
variable "disable-cloud-controller" {
  type        = string
  description = <<-EOT
    (Components) If true, disable the default RKE2 cloud controller manager.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.disable-cloud-controller != null ? can(regex("^(true|false)$", var.disable-cloud-controller)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L447
variable "disable-kube-proxy" {
  type        = string
  description = <<-EOT
    (Components) If true, disable running kube-proxy.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.disable-kube-proxy != null ? can(regex("^(true|false)$", var.disable-kube-proxy)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L78
variable "node-name" {
  type        = string
  description = <<-EOT
    (Agent/node) The name of the node as it will be registered in Kubernetes.
  EOT
  default     = null
  validation {
    condition = (
      var.node-name != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.node-name)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L84
variable "with-node-id" {
  type        = string
  description = <<-EOT
    (Agent/node) If true, append a unique ID to the node name.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.with-node-id != null ? can(regex("^(true|false)$", var.with-node-id)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L189
variable "node-label" {
  type        = list(string)
  description = <<-EOT
    (Agent/node) A list of labels to add to the node during registration.
    e.g., ["foo=bar", "baz=qux"].
  EOT
  # https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
  default = null
  validation {
    condition = (
      var.node-label != null ? can(concat(var.node-label, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set
  validation {
    condition = (
      var.node-label != null ? alltrue([
        for l in var.node-label : can(regex(
          "^(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{1,63}[\\.]){0,4}[[:alnum:]\\p{Pd}]{1,62}[[:alnum:]]/)?[[:alnum:]][\\w\\p{Pd}\\.]{0,61}[[:alnum:]](?:[=](?:[[:alnum:]][\\w\\p{Pd}\\.]{1,61}[[:alnum:]])?)?$",
          l
        ))]
    ) : true)
    error_message = "If specified, value must be a list of Kubernetes labels."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L184
variable "node-taint" {
  type        = list(string)
  description = <<-EOT
    (Agent/node) A list of taints to apply to the node during registration.
    e.g., ["key=value:NoSchedule"].
  EOT
  default     = null
  validation {
    condition = (
      var.node-taint != null ? can(concat(var.node-taint, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the options themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/#syntax
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L194
variable "image-credential-provider-bin-dir" {
  type        = string
  description = <<-EOT
    (Agent/node) The path to the directory containing credential provider plugin binaries.
    Defaults to "/var/lib/rancher/credentialprovider/bin".
  EOT
  default     = null
  validation {
    condition = (
      var.image-credential-provider-bin-dir != null ? can(regex(
        "^/(?:[\\w\\.\\p{Pd}]+[/]?)+$",
        var.image-credential-provider-bin-dir
      )) : true
    )
    error_message = "If specified, value must be a full path."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L200
variable "image-credential-provider-config" {
  type        = string
  description = <<-EOT
    (Agent/node) The path to the configuration file for the credential provider plugin.
    Defaults to "/var/lib/rancher/credentialprovider/config.yaml".
  EOT
  default     = null
  validation {
    condition = (
      var.image-credential-provider-config != null ? can(regex(
        "^/(?:[\\w\\.\\p{Pd}]+[/]?)+$",
        var.image-credential-provider-config
      )) : true
    )
    error_message = "If specified, value must be a full path."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L112
variable "container-runtime-endpoint" {
  type        = string
  description = <<-EOT
    (Agent/runtime) The path to an external container runtime endpoint (CRI socket).
    If set, the embedded containerd will be disabled.
  EOT
  default     = null
  validation {
    condition = (
      var.container-runtime-endpoint != null ? can(regex(
        "^[\\w]+:[/]+(?:[\\w\\.\\p{Pd}]+[/]?)+$",
        var.container-runtime-endpoint
      )) : true
    )
    error_message = "If specified, value must be a full path."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L135
variable "snapshotter" {
  type        = string
  description = <<-EOT
    (Agent/runtime) The name of the containerd snapshotter to use, overriding the default.
    Defaults to "overlayfs".
  EOT
  default     = null
  validation {
    condition = (
      var.snapshotter != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.snapshotter)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L117
variable "private-registry" {
  type        = string
  description = <<-EOT
    (Agent/runtime) The path to a private registry configuration file (registries.yaml).
    Defaults to "/etc/rancher/rke2/registries.yaml".
  EOT
  default     = null
  validation {
    condition = (
      var.private-registry != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.private-registry)) : true
    )
    error_message = "If specified, value must be a full path."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L491
variable "system-default-registry" {
  type        = string
  description = <<-EOT
    (Agent/runtime) A private registry to use for all system images, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.system-default-registry != null ? anytrue([
        can(regex("^(?:https?://)?[[:alpha:]](?:[[:alnum:]\\p{Pd}]{1,62}\\.)+[[:alnum:]\\p{Pd}]{1,62}[[:alnum:]](?::[[:digit:]]{1,5})?$", var.system-default-registry)), # FQDN with optional port and optional protocol
        can(regex("^(?:https?://)?(?:[[:digit:]]{1,3}\\.){3}[[:digit:]]{1,3}(?::[[:digit:]]{1,5})?$", var.system-default-registry)),                                     # IPv4 with optional port and optional protocol
        can(regex("^(?:https?://)?(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4}$", var.system-default-registry)),                                                    # IPv6 with optional protocol
    ]) : true)
    error_message = "If specified, value must be a valid address."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L68
variable "node-ip" {
  type        = list(string)
  description = <<-EOT
    (Agent/networking) A list of IPv4/IPv6 addresses to advertise for the node's internal IP.
  EOT
  default     = null
  validation {
    condition = (
      var.node-ip != null ? can(concat(var.node-ip, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  validation {
    condition = (
      var.node-ip != null ? alltrue([
        for n in var.node-ip : anytrue([
          can(regex("^(?:[[:digit:]]{1,3}\\.){3}[[:digit:]]{1,3}$", n)),        # IPv4
          can(regex("^(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4}$", n)), # IPv6
        ])
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid IPv4 or IPv6 addresses (no port)."
    # https://kubernetes.io/docs/concepts/architecture/nodes/#addresses
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L73
variable "node-external-ip" {
  type        = list(string)
  description = <<-EOT
    (Agent/networking) A list of IPv4/IPv6 addresses to advertise for the node's external IP.
  EOT
  default     = null
  validation {
    condition = (
      var.node-external-ip != null ? can(concat(var.node-external-ip, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  validation {
    condition = (
      var.node-external-ip != null ? alltrue([
        for n in var.node-external-ip : anytrue([
          can(regex("^(?:[[:digit:]]{1,3}\\.){3}[[:digit:]]{1,3}$", n)),        # IPv4
          can(regex("^(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4}$", n)), # IPv6
        ])
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid IPv4 or IPv6 addresses (no port)."
    # https://kubernetes.io/docs/concepts/architecture/nodes/#addresses
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L168
variable "resolv-conf" {
  type        = string
  description = <<-EOT
    (Agent/networking) The path to a custom resolv.conf file for the kubelet to use.
  EOT
  default     = null
  validation {
    condition = (
      var.resolv-conf != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.resolv-conf)) : true
    )
    error_message = "If specified, value must be a valid path."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L174
variable "kubelet-arg" {
  type        = list(string)
  description = <<-EOT
    (Agent/flags) A list of additional arguments to pass to the kubelet process.
    e.g., ["--v=4"].
  EOT
  default     = null
  validation {
    condition = (
      var.kubelet-arg != null ? can(concat(var.kubelet-arg, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
}

# Type(slice): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L179
variable "kube-proxy-arg" {
  type        = list(string)
  description = <<-EOT
    (Agent/flags) A list of additional arguments to pass to the kube-proxy process.
    e.g., ["--v=4"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-proxy-arg != null ? can(concat(var.kube-proxy-arg, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L89
variable "protect-kernel-defaults" {
  type        = string
  description = <<-EOT
    (Agent/node) If true, the agent will error out if kernel tunables are different than kubelet's defaults.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.protect-kernel-defaults != null ? can(regex("^(true|false)$", var.protect-kernel-defaults)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/server.go#L515
variable "enable-pprof" {
  type        = string
  description = <<-EOT
    (Experimental) If true, enable the Go pprof endpoint on the supervisor port for debugging.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.enable-pprof != null ? can(regex("^(true|false)$", var.enable-pprof)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L94
variable "selinux" {
  type        = string
  description = <<-EOT
    (Agent/node) If true, enable SELinux support in containerd.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.selinux != null ? can(regex("^(true|false)$", var.selinux)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(int): https://github.com/k3s-io/k3s/blob/main/pkg/cli/cmds/agent.go#L100
variable "lb-server-port" {
  type        = string
  description = <<-EOT
    (Agent/node) The local port for the supervisor client load-balancer.
    An additional port (port-1) is used if the apiserver is not co-located.
    Defaults to 6444.
  EOT
  default     = null
  validation {
    condition = (
      var.lb-server-port != null ? can(regex("^[[:digit:]]{1,5}$", var.lb-server-port)) : true
    )
    error_message = "If specified, value must be a valid port number."
  }
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/server.go#L24
variable "cni" {
  type        = list(string)
  description = <<-EOT
    (Networking) A list of CNI plugins to deploy.
    Valid options include 'calico', 'canal', 'cilium', or 'none'.
    'multus' can be included as the first item to enable the multus meta-plugin.
    Defaults to "canal".
  EOT
  default     = null
  validation {
    condition = (
      var.cni != null ? can(concat(var.cni, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  validation {
    condition = (
      var.cni != null ? can(regex(
        "^(none|calico|canal|cilium|multus,calico|multus,canal|multus,cilium)$",
        join(",", var.cni)
      )) : true
    )
    error_message = "If specified, value must be one of 'none, calico, canal, cilium'; optionally with multus as the first value."
  }
}

# Type(bool): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/server.go#L30
variable "enable-servicelb" {
  type        = string
  description = <<-EOT
    (Components) If true, enable the ServiceLB (service controller) in the default RKE2 cloud controller manager.
    Defaults to true.
  EOT
  default     = null
  validation {
    condition = (
      var.enable-servicelb != null ? can(regex("^(true|false)$", var.enable-servicelb)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "kube-apiserver-image" {
  type        = string
  description = <<-EOT
    (Image) The container image to use for the kube-apiserver component, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.kube-apiserver-image != null ? can(regex(
        "^(?:(?:https?://)?(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]\\.)+[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]|(?:[[:digit:]]{1,3}\\.){1,3}[[:digit:]]{1,3}|(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4})(?::[[:digit:]]{1,5})?/)?[\\w\\p{Pd}\\.]+(?:/[\\w\\p{Pd}\\.]+)?(?::[\\w\\p{Pd}\\.]+)?$",
        var.kube-apiserver-image
        )
    ) : true)
    error_message = "If specified, value must be an image name."
  }
  # https://kubernetes.io/docs/concepts/containers/images/#image-names
  # image names have an embedded URL for private/non-docker registries
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "kube-controller-manager-image" {
  type        = string
  description = <<-EOT
    (Image) The container image to use for the kube-controller-manager component, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.kube-controller-manager-image != null ? can(regex(
        "^(?:(?:https?://)?(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]\\.)+[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]|(?:[[:digit:]]{1,3}\\.){1,3}[[:digit:]]{1,3}|(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4})(?::[[:digit:]]{1,5})?/)?[\\w\\p{Pd}\\.]+(?:/[\\w\\p{Pd}\\.]+)?(?::[\\w\\p{Pd}\\.]+)?$",
        var.kube-controller-manager-image
        )
    ) : true)
    error_message = "If specified, value must be an image name."
  }
  # https://kubernetes.io/docs/concepts/containers/images/#image-names
  # image names have an embedded URL for private/non-docker registries
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "cloud-controller-manager-image" {
  type        = string
  description = <<-EOT
    (Image) The container image to use for the cloud-controller-manager component, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.cloud-controller-manager-image != null ? can(regex(
        "^(?:(?:https?://)?(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]\\.)+[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]|(?:[[:digit:]]{1,3}\\.){1,3}[[:digit:]]{1,3}|(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4})(?::[[:digit:]]{1,5})?/)?[\\w\\p{Pd}\\.]+(?:/[\\w\\p{Pd}\\.]+)?(?::[\\w\\p{Pd}\\.]+)?$",
        var.cloud-controller-manager-image
        )
    ) : true)
    error_message = "If specified, value must be a valid image name."
    # https://kubernetes.io/docs/concepts/containers/images/#image-names
    # image names have an embedded URL for private/non-docker registries
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "kube-proxy-image" {
  type        = string
  description = <<-EOT
    (Image) The container image to use for the kube-proxy component, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.kube-proxy-image != null ? can(regex(
        "^(?:(?:https?://)?(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]\\.)+[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]|(?:[[:digit:]]{1,3}\\.){1,3}[[:digit:]]{1,3}|(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4})(?::[[:digit:]]{1,5})?/)?[\\w\\p{Pd}\\.]+(?:/[\\w\\p{Pd}\\.]+)?(?::[\\w\\p{Pd}\\.]+)?$",
        var.kube-proxy-image
        )
    ) : true)
    error_message = "If specified, value must be an image name."
    # https://kubernetes.io/docs/concepts/containers/images/#image-names
    # image names have an embedded URL for private/non-docker registries
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "kube-scheduler-image" {
  type        = string
  description = <<-EOT
    (Image) The container image to use for the kube-scheduler component, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.kube-scheduler-image != null ? can(regex(
        "^(?:(?:https?://)?(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]\\.)+[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]|(?:[[:digit:]]{1,3}\\.){1,3}[[:digit:]]{1,3}|(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4})(?::[[:digit:]]{1,5})?/)?[\\w\\p{Pd}\\.]+(?:/[\\w\\p{Pd}\\.]+)?(?::[\\w\\p{Pd}\\.]+)?$",
        var.kube-scheduler-image
        )
    ) : true)
    error_message = "If specified, value must be an image name."
    # https://kubernetes.io/docs/concepts/containers/images/#image-names
    # image names have an embedded URL for private/non-docker registries
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "pause-image" {
  type        = string
  description = <<-EOT
    (Image) The container image to use for the pause container, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.pause-image != null ? can(regex(
        "^(?:(?:https?://)?(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]\\.)+[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]|(?:[[:digit:]]{1,3}\\.){1,3}[[:digit:]]{1,3}|(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4})(?::[[:digit:]]{1,5})?/)?[\\w\\p{Pd}\\.]+(?:/[\\w\\p{Pd}\\.]+)?(?::[\\w\\p{Pd}\\.]+)?$",
        var.pause-image
        )
    ) : true)
    error_message = "If specified, value must be an image name."
    # https://kubernetes.io/docs/concepts/containers/images/#image-names
    # image names have an embedded URL for private/non-docker registries
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "runtime-image" {
  type        = string
  description = <<-EOT
    (Image) The container image to use for runtime binaries (e.g., containerd, crictl), overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.runtime-image != null ? can(regex(
        "^(?:(?:https?://)?(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]\\.)+[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]|(?:[[:digit:]]{1,3}\\.){1,3}[[:digit:]]{1,3}|(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4})(?::[[:digit:]]{1,5})?/)?[\\w\\p{Pd}\\.]+(?:/[\\w\\p{Pd}\\.]+)?(?::[\\w\\p{Pd}\\.]+)?$",
        var.runtime-image
        )
    ) : true)
    error_message = "If specified, value must be an image name."
    # https://kubernetes.io/docs/concepts/containers/images/#image-names
    # image names have an embedded URL for private/non-docker registries
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "etcd-image" {
  type        = string
  description = <<-EOT
    (Image) The container image to use for the etcd component, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-image != null ? can(regex(
        "^(?:(?:https?://)?(?:(?:[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]\\.)+[[:alpha:]][[:alnum:]\\p{Pd}]{0,61}[[:alnum:]]|(?:[[:digit:]]{1,3}\\.){1,3}[[:digit:]]{1,3}|(?:[[:xdigit:]]{0,4}:{1,7}){1,7}[[:xdigit:]]{0,4})(?::[[:digit:]]{1,5})?/)?[\\w\\p{Pd}\\.]+(?:/[\\w\\p{Pd}\\.]+)?(?::[\\w\\p{Pd}\\.]+)?$",
        var.etcd-image
        )
    ) : true)
    error_message = "If specified, value must be a valid image name."
    # https://kubernetes.io/docs/concepts/containers/images/#image-names
    # image names have an embedded URL for private/non-docker registries
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "kubelet-path" {
  type        = string
  description = <<-EOT
    (Experimental/agent) The path to an alternate kubelet binary, overriding the default.
  EOT
  default     = null
  validation {
    condition = (
      var.kubelet-path != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.kubelet-path)) : true
    )
    error_message = "If specified, value must be a valid file path."
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "cloud-provider-name" {
  type        = string
  description = <<-EOT
    (Cloud provider) The name of the external cloud provider to use.
  EOT
  default     = null
  validation {
    condition = (
      var.cloud-provider-name != null ? can(regex(
        "^[\\w-\\.]{1,63}$",
        var.cloud-provider-name
        )
    ) : true)
    error_message = "If specified, value must be a name."
    # using the simple rules for labels and annotations
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go
variable "cloud-provider-config" {
  type        = string
  description = <<-EOT
    (Cloud provider) The path to the configuration file for the external cloud provider.
  EOT
  default     = null
  validation {
    condition = (
      var.cloud-provider-config != null ? can(regex("^/(?:[\\w\\-\\.]+[/]?)+$", var.cloud-provider-config)) : true
    )
    error_message = "If specified, value must be a valid file path."
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L85
# Default: https://github.com/rancher/rke2/blob/master/pkg/rke2/rke2.go#L66
variable "profile" {
  type        = string
  description = <<-EOT
    (Security) The security profile to validate the system configuration against (e.g., 'cis-1.23').
  EOT
  default     = null
  validation {
    condition = (
      var.profile != null ? can(regex(
        "^[\\w\\p{Pd}\\.]{1,63}$",
        var.profile
        )
    ) : true)
    error_message = "If specified, value must be a name."
    # using the simple rules for labels and annotations
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L90
variable "audit-policy-file" {
  type        = string
  description = <<-EOT
    (Security) The path to a file defining the audit policy configuration.
  EOT
  default     = null
  validation {
    condition = (
      var.audit-policy-file != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.audit-policy-file)) : true
    )
    error_message = "If specified, value must be a valid file path."
  }
}
# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L96
variable "pod-security-admission-config-file" {
  type        = string
  description = <<-EOT
    (Security) The path to a file defining the Pod Security Admission configuration.
  EOT
  default     = null
  validation {
    condition = (
      var.pod-security-admission-config-file != null ? can(regex(
        "^/(?:[\\w\\.\\p{Pd}]+[/]?)+$",
        var.pod-security-admission-config-file
      )) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L102
variable "control-plane-resource-requests" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of resource requests for control plane components.
    e.g., ["cpu=100m", "memory=256Mi"].
  EOT
  default     = null
  validation {
    condition = (
      var.control-plane-resource-requests != null ? can(concat(var.control-plane-resource-requests, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L108
variable "control-plane-resource-limits" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of resource limits for control plane components.
    e.g., ["cpu=200m", "memory=512Mi"].
  EOT
  default     = null
  validation {
    condition = (
      var.control-plane-resource-limits != null ? can(concat(var.control-plane-resource-limits, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L114
variable "control-plane-probe-configuration" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of probe configurations for control plane components.
    e.g., ["liveness:initialDelaySeconds=15"].
  EOT
  default     = null
  validation {
    condition = (
      var.control-plane-probe-configuration != null ? can(concat(var.control-plane-probe-configuration, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L120
variable "kube-apiserver-extra-mount" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra volume mounts for the kube-apiserver.
    e.g., ["/path/on/host:/path/in/container"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-apiserver-extra-mount != null ? can(concat(var.kube-apiserver-extra-mount, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/storage/volumes/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L126
variable "kube-scheduler-extra-mount" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra volume mounts for the kube-scheduler.
    e.g., ["/path/on/host:/path/in/container"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-scheduler-extra-mount != null ? can(concat(var.kube-scheduler-extra-mount, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/storage/volumes/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L132
variable "kube-controller-manager-extra-mount" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra volume mounts for the kube-controller-manager.
    e.g., ["/path/on/host:/path/in/container"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-controller-manager-extra-mount != null ? can(concat(var.kube-controller-manager-extra-mount, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/storage/volumes/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L138
variable "kube-proxy-extra-mount" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra volume mounts for the kube-proxy.
    e.g., ["/path/on/host:/path/in/container"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-proxy-extra-mount != null ? can(concat(var.kube-proxy-extra-mount, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/storage/volumes/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L144
variable "etcd-extra-mount" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra volume mounts for etcd.
    e.g., ["/path/on/host:/path/in/container"].
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-extra-mount != null ? can(concat(var.etcd-extra-mount, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/storage/volumes/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L150
variable "cloud-controller-manager-extra-mount" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra volume mounts for the cloud-controller-manager.
    e.g., ["/path/on/host:/path/in/container"].
  EOT
  default     = null
  validation {
    condition = (
      var.cloud-controller-manager-extra-mount != null ? can(concat(var.cloud-controller-manager-extra-mount, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/storage/volumes/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L156
variable "kube-apiserver-extra-env" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra environment variables for the kube-apiserver.
    e.g., ["KEY=VALUE"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-apiserver-extra-env != null ? can(concat(var.kube-apiserver-extra-env, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/workloads/pods/downward-api/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L162
variable "kube-scheduler-extra-env" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra environment variables for the kube-scheduler.
    e.g., ["KEY=VALUE"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-scheduler-extra-env != null ? can(concat(var.kube-scheduler-extra-env, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/workloads/pods/downward-api/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L168
variable "kube-controller-manager-extra-env" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra environment variables for the kube-controller-manager.
    e.g., ["KEY=VALUE"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-controller-manager-extra-env != null ? can(concat(var.kube-controller-manager-extra-env, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/workloads/pods/downward-api/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L174
variable "kube-proxy-extra-env" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra environment variables for the kube-proxy.
    e.g., ["KEY=VALUE"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-proxy-extra-env != null ? can(concat(var.kube-proxy-extra-env, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/workloads/pods/downward-api/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L180
variable "etcd-extra-env" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra environment variables for etcd.
    e.g., ["KEY=VALUE"].
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-extra-env != null ? can(concat(var.etcd-extra-env, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/workloads/pods/downward-api/
}

# Type(slice): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L186
variable "cloud-controller-manager-extra-env" {
  type        = list(string)
  description = <<-EOT
    (Components) A list of extra environment variables for the cloud-controller-manager.
    e.g., ["KEY=VALUE"].
  EOT
  default     = null
  validation {
    condition = (
      var.cloud-controller-manager-extra-env != null ? can(concat(var.cloud-controller-manager-extra-env, [])) : true
    )
    error_message = "If specified, value must be a Terraform list."
  }
  # the args themselves are too complex to be validated here
  # https://kubernetes.io/docs/concepts/workloads/pods/downward-api/
}

## These variables are for the module, not the rke2 config
variable "local_file_path" {
  type        = string
  description = <<-EOT
    A local file path to store the config output.
    Will use the root module directory by default.
  EOT
  default     = ""
}
variable "local_file_name" {
  type        = string
  description = <<-EOT
    A local file name to store the config output.
  EOT
  default     = "50-initial-generated-config.yaml"
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20datastore-cafile&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20datastore-cafile&type=code
# Type(string): 
variable "datastore-cafile" {
  type        = string
  description = <<-EOT
    (db) The path to a PEM-encoded CA file for verifying the TLS certificate of an external datastore.
  EOT
  default     = null
  validation {
    condition = (
      var.datastore-cafile != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.datastore-cafile)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20datastore-certfile&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20datastore-certfile&type=code
# Type(?):
variable "datastore-certfile" {
  type        = string
  description = <<-EOT
    (db) The path to a PEM-encoded client certificate file for mTLS authentication with an external datastore.
  EOT
  default     = null
  validation {
    condition = (
      var.datastore-certfile != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.datastore-certfile)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20datastore-endpoint&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20datastore-endpoint&type=code
# Type(?):
variable "datastore-endpoint" {
  type        = string
  description = <<-EOT
    (db) The connection string (DSN) for an external datastore (e.g., etcd, NATS, MySQL, Postgres).
  EOT
  default     = null
  # DSN strings are too complex for simple regex validation.
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20datastore-keyfile&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20datastore-keyfile&type=code
# Type(?):
variable "datastore-keyfile" {
  type        = string
  description = <<-EOT
    (db) The path to the PEM-encoded private key file corresponding to the 'datastore-certfile' for mTLS authentication.
  EOT
  default     = null
  validation {
    condition = (
      var.datastore-keyfile != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.datastore-keyfile)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20default-runtime&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20default-runtime&type=code
# Type(?):
variable "default-runtime" {
  type        = string
  description = <<-EOT
    (agent/runtime) The default container runtime to use in containerd, useful in multi-runtime configurations.
  EOT
  default     = null
  validation {
    condition = (
      var.default-runtime != null ? can(regex("^[a-zA-Z0-9_.-]+$", var.default-runtime)) : true
    )
    error_message = "If specified, value must be a valid runtime name."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20disable-default-registry-endpoint&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20disable-default-registry-endpoint&type=code
# Type(?):
variable "disable-default-registry-endpoint" {
  type        = string
  description = <<-EOT
    (agent/containerd) If true, disables containerd's fallback to the default registry (e.g., docker.io) when a private mirror is configured.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.disable-default-registry-endpoint != null ? can(regex("^(true|false)$", var.disable-default-registry-endpoint)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20embedded-registry&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20embedded-registry&type=code
# Type(?):
variable "embedded-registry" {
  type        = string
  description = <<-EOT
    (components) If true, enable the experimental embedded container registry.
    This requires the embedded containerd runtime. Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.embedded-registry != null ? can(regex("^(true|false)$", var.embedded-registry)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-bucket-lookup-type&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-bucket-lookup-type&type=code
# Type(?):
variable "etcd-s3-bucket-lookup-type" {
  type        = string
  description = <<-EOT
    (db) The S3 bucket lookup style.
    Must be one of 'auto', 'dns', or 'path'.
    Defaults to 'auto'.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-bucket-lookup-type != null ? can(regex("^(auto|dns|path)$", var.etcd-s3-bucket-lookup-type)) : true
    )
    error_message = "If specified, value must be one of 'auto', 'dns', or 'path'."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-config-secret&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-config-secret&type=code
# Type(?):
variable "etcd-s3-config-secret" {
  type        = string
  description = <<-EOT
    (db) The name of a Kubernetes Secret in the 'kube-system' namespace containing S3 credentials.
    Used if other 'etcd-s3-*' flags are not set.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-config-secret != null ? can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.etcd-s3-config-secret)) : true
    )
    error_message = "If specified, value must be a valid Kubernetes secret name."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-proxy&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-proxy&type=code
# Type(?):
variable "etcd-s3-proxy" {
  type        = string
  description = <<-EOT
    (db) A proxy server URL to use for S3 connections, overriding system-wide proxy environment variables.
  EOT
  default     = null
  # URL validation is complex, deferring to RKE2.
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-retention&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-retention&type=code
# Type(?):
variable "etcd-s3-retention" {
  type        = string
  description = <<-EOT
    (db) The number of S3 snapshots to retain.
    Older snapshots are automatically deleted. Defaults to 5.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-retention != null ? can(regex("^[0-9]+$", var.etcd-s3-retention)) : true
    )
    error_message = "If specified, value must be a number."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-session-token&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-s3-session-token&type=code
# Type(?):
variable "etcd-s3-session-token" {
  type        = string
  description = <<-EOT
    (db) The AWS session token for S3 authentication,
    typically used with temporary credentials from an STS service.
  EOT
  default     = null
  sensitive   = true
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-snapshot-reconcile-interval&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20etcd-snapshot-reconcile-interval&type=code
# Type(?):
variable "etcd-snapshot-reconcile-interval" {
  type        = string
  description = <<-EOT
    (db) The interval to reconcile local and S3 snapshots, specified as a Go duration string (e.g., '10m').
    Defaults to '10m0s'.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-snapshot-reconcile-interval != null ? can(regex("^[0-9]+[smh]$", var.etcd-snapshot-reconcile-interval)) : true
    )
    error_message = "If specified, value must be a Go duration string (e.g., '10m', '1h')."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20helm-job-image&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20helm-job-image&type=code
# Type(?):
variable "helm-job-image" {
  type        = string
  description = <<-EOT
    (helm) The container image for running Helm jobs, such as installing packaged components.
  EOT
  default     = null
  # Image name validation is complex, deferring to RKE2.
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20ingress-controller&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20ingress-controller&type=code
# Type(?):
variable "ingress-controller" {
  type        = string
  description = <<-EOT
    (networking) The ingress controller to deploy.
    Must be one of 'none', 'ingress-nginx', or 'traefik'.
    Defaults to 'ingress-nginx'.
  EOT
  default     = null
  validation {
    condition = (
      var.ingress-controller != null ? can(regex("^(none|ingress-nginx|traefik)$", var.ingress-controller)) : true
    )
    error_message = "If specified, value must be one of 'none', 'ingress-nginx', or 'traefik'."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20kube-cloud-controller-manager-arg&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20kube-cloud-controller-manager-arg&type=code
# Type(?):
variable "kube-cloud-controller-manager-arg" {
  type        = list(string)
  description = <<-EOT
    (flags) A list of additional arguments to pass to the kube-cloud-controller-manager process.
    e.g., ["--v=4"].
  EOT
  default     = null
  validation {
    condition = (
      var.kube-cloud-controller-manager-arg != null ? can(concat(var.kube-cloud-controller-manager-arg, [])) : true
    )
    error_message = "If specified, value must be a list of strings."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20node-external-dns&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20node-external-dns&type=code
# Type(?):
variable "node-external-dns" {
  type        = list(string)
  description = <<-EOT
    (agent/networking) A list of external DNS server IP addresses for the node to use.
  EOT
  default     = null
  validation {
    condition = (
      var.node-external-dns != null ? alltrue([for ip in var.node-external-dns : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))]) : true
    )
    error_message = "If specified, value must be a list of valid IPv4 addresses."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20node-internal-dns&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20node-internal-dns&type=code
# Type(?):
variable "node-internal-dns" {
  type        = list(string)
  description = <<-EOT
    (agent/networking) A list of internal DNS server IP addresses for the node to use.
  EOT
  default     = null
  validation {
    condition = (
      var.node-internal-dns != null ? alltrue([for ip in var.node-internal-dns : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))]) : true
    )
    error_message = "If specified, value must be a list of valid IPv4 addresses."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20node-name-from-cloud-provider-metadata&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20node-name-from-cloud-provider-metadata&type=code
# Type(?):
variable "node-name-from-cloud-provider-metadata" {
  type        = string
  description = <<-EOT
    (cloud provider) If true, the agent will get its node name from the cloud provider's instance metadata service.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.node-name-from-cloud-provider-metadata != null ? can(regex("^(true|false)$", var.node-name-from-cloud-provider-metadata)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20nonroot-devices&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20nonroot-devices&type=code
# Type(?):
variable "nonroot-devices" {
  type        = string
  description = <<-EOT
    (agent/containerd) If true, allows non-root pods to access devices by setting
     'device_ownership_from_security_context=true' in the containerd CRI config.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.nonroot-devices != null ? can(regex("^(true|false)$", var.nonroot-devices)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20secrets-encryption-provider&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20secrets-encryption-provider&type=code
# Type(?):
variable "secrets-encryption-provider" {
  type        = string
  description = <<-EOT
    (experimental) The encryption provider for Kubernetes secrets at rest.
    Must be 'aescbc' or 'secretbox'.
    Defaults to 'aescbc'.
  EOT
  default     = null
  validation {
    condition = (
      var.secrets-encryption-provider != null ? can(regex("^(aescbc|secretbox)$", var.secrets-encryption-provider)) : true
    )
    error_message = "If specified, value must be one of 'aescbc' or 'secretbox'."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20supervisor-metrics&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20supervisor-metrics&type=code
# Type(?):
variable "supervisor-metrics" {
  type        = string
  description = <<-EOT
    (experimental/components) If true, enable an endpoint for serving internal RKE2 metrics on the supervisor port.
    Defaults to false.
  EOT
  default     = null
  validation {
    condition = (
      var.supervisor-metrics != null ? can(regex("^(true|false)$", var.supervisor-metrics)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# k3s: https://github.com/search?q=repo%3Ak3s-io%2Fk3s%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20write-kubeconfig-group&type=code
# rke2: https://github.com/search?q=repo%3Arancher%2Frke2%20path%3Apkg%2Fcli%2Fcmds%2Fserver.go%20write-kubeconfig-group&type=code
# Type(?):
variable "write-kubeconfig-group" {
  type        = string
  description = <<-EOT
    (client) The group ownership for the generated kubeconfig file.
  EOT
  default     = null
  validation {
    condition = (
      var.write-kubeconfig-group != null ? can(regex("^[a-zA-Z0-9_.-]+$", var.write-kubeconfig-group)) : true
    )
    error_message = "If specified, value must be a valid group name."
  }
}
