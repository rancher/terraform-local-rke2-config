# Validations in this file are not exhaustive, but meant to validate input types and formats.
# All variables should have a default value of "" (empty string) to indicate that the user wants to use the default RKE2 value.
# This means that all variables are optional, and the user can choose to override any value.
# When a user overrides a value, we use the validation block to ensure that the value is of the correct type and format.


# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/root.go#L14
# Default: https://github.com/golang/go/blob/go1.20.5/src/sync/atomic/type.go#L35
variable "debug" {
  type        = string
  description = <<-EOT
    (Logging) Turn on debug logs.
    Defaults to false (Go default).
  EOT
  default     = null
  validation {
    condition = (
      var.debug != null ? can(regex("^(true|false)$", var.debug)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L178
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L104
variable "bind-address" {
  type        = string
  description = <<-EOT
    (Listener) rke2 bind address.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L189
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/server/server.go#L241
variable "advertise-address" {
  type        = string
  description = <<-EOT
    (Listener) IPv4 address that apiserver uses to advertise to members of the cluster.
    Defaults to the external node address or the node address if external is not set.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L199
# Defaults(kubernetes): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/deps/deps.go#L429
# Defaults(localhost): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/server/server.go#L267
# Defaults(hostname): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/util/net.go#L162
variable "tls-san" {
  type        = list(string)
  description = <<-EOT
    (Listener) Add additional hostnames or IPv4/IPv6 addresses as Subject Alternative Names on the server TLS cert.
    Defaults to "kubernetes", "kubernetes.default", "kubernetes.default.svc", "kubernetes.default.svc.cluster.local", "127.0.0.1","::1", "localhost", and your server's hostname.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L111
# Type override: https://github.com/rancher/rke2/blob/v1.27.3+rke2r1/pkg/cli/cmds/server.go#L49
# Default: https://github.com/rancher/rke2/blob/v1.27.3+rke2r1/pkg/cli/cmds/server.go#L15
variable "data-dir" {
  type        = string
  description = <<-EOT
    (Data) Folder to hold state.
    Defaults to "/var/lib/rancher/rke2"
  EOT
  default     = null
  validation {
    condition = (
      var.data-dir != null ? can(regex("^/(?:[\\w\\-\\.]+[/]?)+$", var.data-dir)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L122
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L223
variable "cluster-cidr" {
  type        = list(string)
  description = <<-EOT
    (Networking) IPv4/IPv6 network CIDRs to use for pod IPs.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L127
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L228
variable "service-cidr" {
  type        = list(string)
  description = <<-EOT
    (Networking) IPv4/IPv6 network CIDRs to use for service IPs.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L132
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L136
variable "service-node-port-range" {
  type        = string
  description = <<-EOT
    (Networking) Port range to reserve for services with NodePort visibility.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L138
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L233
variable "cluster-dns" {
  type        = list(string)
  description = <<-EOT
    (Networking) IPv4 Cluster IP for coredns service. Should be in your service-cidr range.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L143
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L147
variable "cluster-domain" {
  type        = string
  description = <<-EOT
    (Networking) Cluster Domain.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L232
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L235
variable "egress-selector-mode" {
  type        = string
  description = <<-EOT
    (Networking) One of 'agent', 'cluster', 'pod', 'disabled'.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L238
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L241
variable "servicelb-namespace" {
  type        = string
  description = <<-EOT
    (Networking) Namespace of the pods for the servicelb component.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L243
# Default(directory): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/datadir/datadir.go#L16
# Default(path): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/server/server.go#L435
variable "write-kubeconfig" {
  type        = string
  description = <<-EOT
    (Client) Write kubeconfig for admin client to this file.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L249
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/server/server.go#L468
variable "write-kubeconfig-mode" {
  type        = string
  description = <<-EOT
    (Client) Write kubeconfig with this mode.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L116
# Default(call to generate): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/kubeadm/token.go#L45
# Default(generate): https://github.com/kubernetes/cluster-bootstrap/blob/v0.27.3/token/util/helpers.go#L45
# Default(random): https://github.com/kubernetes/cluster-bootstrap/blob/v0.27.3/token/util/helpers.go#L61
variable "token" {
  type        = string
  description = <<-EOT
    (Cluster) Shared secret used to join a server or agent to a cluster.
    If no token or token file is set, a random token will be generated.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L256
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cluster/storage.go#L125
variable "token-file" {
  type        = string
  description = <<-EOT
    (Cluster) File containing the token.
    Defaults to "/var/lib/rancher/rke2/server/token".
    This is ignored if token is set. 
    If no token or token-file is set, a random token will be generated.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L262
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cluster/bootstrap.go#L440
variable "agent-token" {
  type        = string
  description = <<-EOT
    (Cluster) Shared secret used to join agents to the cluster, but not servers.
    Defaults to the value of token.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L268
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/server/server.go#L396
variable "agent-token-file" {
  type        = string
  description = <<-EOT
    (Cluster) File containing the agent secret.
    Defaults to "/var/lib/rancher/rke2/server/agent-token".
    This is ignored if agent-token is set.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L274
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/server/server.go#L115
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/server/server.go#L493
# Default(loopback): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/config/types.go#L258
variable "server" {
  type        = string
  description = <<-EOT
    (Cluster) Server to connect to, used to join a cluster.
    Defaults to bind address and management port, if not otherwise set "https://127.0.0.1:6443".
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

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L286
# Default: https://github.com/golang/go/blob/go1.20.5/src/sync/atomic/type.go#L35
variable "cluster-reset" {
  type        = string
  description = <<-EOT
    (Cluster) Forget all peers and become sole member of a new cluster.
    Defaults to false (Go default).
  EOT
  default     = null
  validation {
    condition = (
      var.cluster-reset != null ? can(regex("^(true|false)$", var.cluster-reset)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L292
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/etcd/etcd.go#L270
# Default(snapshot dir): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/etcd/etcd.go#L1184
variable "cluster-reset-restore-path" {
  type        = string
  description = <<-EOT
    (Db) Path to snapshot file to be restored.
    This doesn't make sense without cluster-reset = true.
    Default snapshot path is "/var/lib/rancher/rke2/server/db/snapshots".
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L149
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L153
variable "kube-apiserver-arg" {
  type        = list(string)
  description = <<-EOT
    (Flags) Customized flag for kube-apiserver process.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L154
variable "etcd-arg" {
  type        = list(string)
  description = <<-EOT
    (Flags) Customized flag for etcd process.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L164
variable "kube-controller-manager-arg" {
  type        = list(string)
  description = <<-EOT
    (Flags) Customized flag for kube-controller-manager process.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L159
variable "kube-scheduler-arg" {
  type        = list(string)
  description = <<-EOT
    (Flags) Customized flag for kube-scheduler process.
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

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L330
variable "etcd-expose-metrics" {
  type        = string
  description = <<-EOT
    (Db) Expose etcd metrics to client interface.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-expose-metrics != null ? can(regex("^(true|false)$", var.etcd-expose-metrics)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L335
variable "etcd-disable-snapshots" {
  type        = string
  description = <<-EOT
    (Db) Disable automatic etcd snapshots.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-disable-snapshots != null ? can(regex("^(true|false)$", var.etcd-disable-snapshots)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L340
variable "etcd-snapshot-name" {
  type        = string
  description = <<-EOT
    (Db) Set the base name of etcd snapshots.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L346
variable "etcd-snapshot-schedule-cron" {
  type        = string
  description = <<-EOT
    (Db) Snapshot interval time in cron spec. eg. every 5 hours '0 */5 * * *'.
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

# Type(int): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L352
variable "etcd-snapshot-retention" {
  type        = string
  description = <<-EOT
    (Db) Number of snapshots to retain.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L358
variable "etcd-snapshot-dir" {
  type        = string
  description = <<-EOT
    (Db) Directory to save db snapshots.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-snapshot-dir != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.etcd-snapshot-dir)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L363
variable "etcd-snapshot-compress" {
  type        = string
  description = <<-EOT
    (Db) Compress etcd snapshot.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-snapshot-compress != null ? can(regex("^(true|false)$", var.etcd-snapshot-compress)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L368
variable "etcd-s3" {
  type        = string
  description = <<-EOT
    (Db) Enable backup to S3.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3 != null ? can(regex("^(true|false)$", var.etcd-s3)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L373
variable "etcd-s3-endpoint" {
  type        = string
  description = <<-EOT
    (Db) S3 endpoint url.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L379
variable "etcd-s3-endpoint-ca" {
  type        = string
  description = <<-EOT
    (Db) S3 custom CA cert to connect to S3 endpoint.
    Path to a PEM-encoded CA cert file to use to verify the S3 endpoint.
    This is only necessary if the S3 endpoint is using a custom CA.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-endpoint-ca != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.etcd-s3-endpoint-ca)) : true
    )
    error_message = "If specified, value must be a full file path."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L384
variable "etcd-s3-skip-ssl-verify" {
  type        = string
  description = <<-EOT
    (Db) Disables S3 SSL certificate validation.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-skip-ssl-verify != null ? can(regex("^(true|false)$", var.etcd-s3-skip-ssl-verify)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L389
variable "etcd-s3-access-key" {
  type        = string
  description = <<-EOT
    (Db) S3 access key id.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L395
variable "etcd-s3-secret-key" {
  type        = string
  description = <<-EOT
    (Db) S3 secret access key.
  EOT
  default     = null
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L401
variable "etcd-s3-bucket" {
  type        = string
  description = <<-EOT
    (Db) S3 bucket name.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-bucket != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.etcd-s3-bucket)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L406
variable "etcd-s3-region" {
  type        = string
  description = <<-EOT
    (Db) S3 region / bucket location.
    Defaults to us-east-1.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-region != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.etcd-s3-region)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L412
variable "etcd-s3-folder" {
  type        = string
  description = <<-EOT
    (Db) S3 folder.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-folder != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.etcd-s3-folder)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L417
variable "etcd-s3-insecure" {
  type        = string
  description = <<-EOT
    (Db) Disables S3 over HTTPS.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-insecure != null ? can(regex("^(true|false)$", var.etcd-s3-insecure)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(duration): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L422
variable "etcd-s3-timeout" {
  type        = string
  description = <<-EOT
    (Db) S3 timeout.
    Defaults to 5m.
  EOT
  default     = null
  validation {
    condition = (
      var.etcd-s3-timeout != null ? can(regex("^[\\d]+[smh]$", var.etcd-s3-timeout)) : true
    )
    error_message = "If specified, value must be a string duration ([\\d]+[smh])."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L433
variable "disable" {
  type        = list(string)
  description = <<-EOT
    (Components) Do not deploy packaged components and delete any deployed components.
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

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L437
variable "disable-scheduler" {
  type        = string
  description = <<-EOT
    (Components) Disable Kubernetes default scheduler.
  EOT
  default     = null
  validation {
    condition = (
      var.disable-scheduler != null ? can(regex("^(true|false)$", var.disable-scheduler)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L442
variable "disable-cloud-controller" {
  type        = string
  description = <<-EOT
    (Components) Disable rke2 default cloud controller manager.
  EOT
  default     = null
  validation {
    condition = (
      var.disable-cloud-controller != null ? can(regex("^(true|false)$", var.disable-cloud-controller)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L447
variable "disable-kube-proxy" {
  type        = string
  description = <<-EOT
    (Components) Disable running kube-proxy.
  EOT
  default     = null
  validation {
    condition = (
      var.disable-kube-proxy != null ? can(regex("^(true|false)$", var.disable-kube-proxy)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L78
variable "node-name" {
  type        = string
  description = <<-EOT
    (Agent/node) Node name.
  EOT
  default     = null
  validation {
    condition = (
      var.node-name != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.node-name)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L84
variable "with-node-id" {
  type        = string
  description = <<-EOT
    (Agent/node) Append id to node name.
  EOT
  default     = null
  validation {
    condition = (
      var.with-node-id != null ? can(regex("^(true|false)$", var.with-node-id)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L189
variable "node-label" {
  type        = list(string)
  description = <<-EOT
    (Agent/node) Registering and starting kubelet with set of labels.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L184
variable "node-taint" {
  type        = list(string)
  description = <<-EOT
    (Agent/node) Registering kubelet with set of taints.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L194
variable "image-credential-provider-bin-dir" {
  type        = string
  description = <<-EOT
    (Agent/node) The path to the directory where credential provider plugin binaries are located.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L200
variable "image-credential-provider-config" {
  type        = string
  description = <<-EOT
    (Agent/node) The path to the credential provider plugin config file.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L112
variable "container-runtime-endpoint" {
  type        = string
  description = <<-EOT
    (Agent/runtime) Disable embedded containerd and use the CRI socket at the given path; 
    when used with --docker this sets the docker socket path.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L135
variable "snapshotter" {
  type        = string
  description = <<-EOT
    (Agent/runtime) Override default containerd snapshotter.
  EOT
  default     = null
  validation {
    condition = (
      var.snapshotter != null ? can(regex("^[[:alnum:]][[:alnum:]\\p{Pd}\\.]{1,61}[[:alnum:]]$", var.snapshotter)) : true
    )
    error_message = "If specified, value must be an RFC-1123 label name."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L117
variable "private-registry" {
  type        = string
  description = <<-EOT
    (Agent/runtime) Private registry configuration file.
  EOT
  default     = null
  validation {
    condition = (
      var.private-registry != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.private-registry)) : true
    )
    error_message = "If specified, value must be a full path."
  }
}

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L491
variable "system-default-registry" {
  type        = string
  description = <<-EOT
    (Agent/runtime) Private registry to be used for all system images.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L68
variable "node-ip" {
  type        = list(string)
  description = <<-EOT
    (Agent/networking) IPv4/IPv6 addresses to advertise for node.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L73
variable "node-external-ip" {
  type        = list(string)
  description = <<-EOT
    (Agent/networking) IPv4/IPv6 external IP addresses to advertise for node.
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

# Type(string): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L168
variable "resolv-conf" {
  type        = string
  description = <<-EOT
    (Agent/networking) Kubelet resolv.conf file.
  EOT
  default     = null
  validation {
    condition = (
      var.resolv-conf != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.resolv-conf)) : true
    )
    error_message = "If specified, value must be a valid path."
  }
}

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L174
variable "kubelet-arg" {
  type        = list(string)
  description = <<-EOT
    (Agent/flags) Customized flag for kubelet process.
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

# Type(slice): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L179
variable "kube-proxy-arg" {
  type        = list(string)
  description = <<-EOT
    (Agent/flags) Customized flag for kube-proxy process.
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

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L89
variable "protect-kernel-defaults" {
  type        = string
  description = <<-EOT
    (Agent/node) Kernel tuning behavior. If set, error if kernel tunables are different than kubelet defaults.
  EOT
  default     = null
  validation {
    condition = (
      var.protect-kernel-defaults != null ? can(regex("^(true|false)$", var.protect-kernel-defaults)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L515
variable "enable-pprof" {
  type        = string
  description = <<-EOT
    (Experimental) Enable pprof endpoint on supervisor port.
  EOT
  default     = null
  validation {
    condition = (
      var.enable-pprof != null ? can(regex("^(true|false)$", var.enable-pprof)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(bool): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L94
variable "selinux" {
  type        = string
  description = <<-EOT
    (Agent/node) Enable SELinux in containerd.
  EOT
  default     = null
  validation {
    condition = (
      var.selinux != null ? can(regex("^(true|false)$", var.selinux)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(int): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L100
variable "lb-server-port" {
  type        = string
  description = <<-EOT
    (Agent/node) Local port for supervisor client load-balancer.
    If the supervisor and apiserver are not colocated an 
    additional port 1 less than this port will also be used for the 
    apiserver client load-balancer.
  EOT
  default     = null
  validation {
    condition = (
      var.lb-server-port != null ? can(regex("^[[:digit:]]{1,5}$", var.lb-server-port)) : true
    )
    error_message = "If specified, value must be a valid port number."
  }
}

# Type(slice): https://github.com/rancher/rke2/blob/v1.27.3%2Brke2r1/pkg/cli/cmds/server.go#L24
variable "cni" {
  type        = list(string)
  description = <<-EOT
    (Networking) CNI Plugins to deploy, one of 'none, calico, canal, cilium'; 
    optionally with multus as the first value to enable the multus meta-plugin.
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

# Type(bool): https://github.com/rancher/rke2/blob/v1.27.3%2Brke2r1/pkg/cli/cmds/server.go#L30
variable "enable-servicelb" {
  type        = string
  description = <<-EOT
    (Components) Enable rke2 default cloud controller manager's service controller.
  EOT
  default     = null
  validation {
    condition = (
      var.enable-servicelb != null ? can(regex("^(true|false)$", var.enable-servicelb)) : true
    )
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L19
variable "kube-apiserver-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for kube-apiserver.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L25
variable "kube-controller-manager-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for kube-controller-manager.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L32
variable "cloud-controller-manager-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for cloud-controller-manager.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L37
variable "kube-proxy-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for kube-proxy.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L43
variable "kube-scheduler-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for kube-scheduler.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L49
variable "pause-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for pause.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L55
variable "runtime-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for runtime binaries.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L61
variable "etcd-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for etcd.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L67
variable "kubelet-path" {
  type        = string
  description = <<-EOT
    (Experimental/agent) Override kubelet binary path.
  EOT
  default     = null
  validation {
    condition = (
      var.kubelet-path != null ? can(regex("^/(?:[\\w\\.\\p{Pd}]+[/]?)+$", var.kubelet-path)) : true
    )
    error_message = "If specified, value must be a valid file path."
  }
}

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L73
variable "cloud-provider-name" {
  type        = string
  description = <<-EOT
    (Cloud provider) Cloud provider name.
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

# Type(string): https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L80
variable "cloud-provider-config" {
  type        = string
  description = <<-EOT
    (Cloud provider) Cloud provider configuration file path.
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
    (Security) Validate system configuration against the selected benchmark.
    Defaults to 'cis-1.23'.
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
    (Security) Path to the file that defines the audit policy configuration.
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
    (Security) Path to the file that defines Pod Security Admission configuration.
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
    (Components) Control Plane resource requests.
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
    (Components) Control Plane resource limits.
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
    (Components) Control Plane Probe configuration.
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
    (Components) kube-apiserver extra volume mounts.
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
    (Components) kube-scheduler extra volume mounts.
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
    (Components) kube-controller-manager extra volume mounts.
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
    (Components) kube-proxy extra volume mounts.
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
    (Components) etcd extra volume mounts.
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
    (Components) cloud-controller-manager extra volume mounts.
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
    (Components) kube-apiserver extra environment variables.
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
    (Components) kube-scheduler extra environment variables.
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
    (Components) kube-controller-manager extra environment variables.
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
    (Components) kube-proxy extra environment variables.
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
    (Components) etcd extra environment variables.
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
    (Components) cloud-controller-manager extra environment variables.
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
