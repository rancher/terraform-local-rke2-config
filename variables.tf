# https://regex101.com/r/7ACd78/1

# "^(?:https?://)?(?:[0-9]{1,3}\\.){3}[0-9]{1,3}(?::[0-9]{1,5})?$|^(?:https?://)?(?:[a-z0-9-]{1,63}\\.)+[a-z0-9-]{1,63}(?::[0-9]{1,5})?$|^(?:https?://)?(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$"
# "^(?:https?://)?" optional http(s):// prefix
# "(?::[0-9]{1,5})?" optional port suffix
# "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$" simple IPv4
# "^[a-z0-9-]{1,253}$" simple Namespace
# "^(?:[a-z0-9-]{1,63}\\.)+[a-z0-9-]{1,63}$" simple Domain
# "^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$" simple IPv6

# Boolean regex:    "^(true|false)$"
# File path regex:  "^/(?:[a-zA-Z0-9_.-]+[/]?)+$"
# File mode regex:  "^(?:0[0-7]{3})$"
# Cron expression regex: "^((\\*(\\/\\d+)?|,|[0-5]?[0-9](-[0-5]?[0-9])?(,[0-5]?[0-9](-[0-5]?[0-9])?)*)\\s){4}((\\*(\\/\\d+)?|,|[0-7](-[0-7])?(,[0-7](-[0-7])?)*))$"

# k8s label regex: "^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$"
# https://regex101.com/r/fmS7Zk/1

# String IP address validation
# validation {
#   condition = (
#     var.b != "" ? anytrue([
#       can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.b)),
#       can(regex("^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$", var.v)),
#     ]) : true
#   )
#   error_message = "If an address is specified, it must be a valid IPv4 or IPv6 address."
# }

# List IP address validation
# validation {
#   condition = (
#     var.cluster-dns != "" ? alltrue([
#       for c in split(",", var.cluster-dns) : anytrue([
#         can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", c)),
#         can(regex("^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$", c)),
#       ])
#     ]) : true
#   )
#   error_message = "If specified, value must be a comma-separated list of valid IPv4 or IPv6 addresses."
# }

# List of k8s labels validation
# validation {
#   condition = (var.node-label != "" ? alltrue([
#     for label in split(",", var.node-label) :
#     alltrue([for l in split("=", label) :
#       can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", label))
#     ])
#     ]) : true
#   )
#   error_message = "If specified, value must be a valid comma separated list of kubernetes labels (k/v)."
#}


# Validations in this file are not exhaustive, but meant to validate input types and formats.
# All variables should have a default value of "" (empty string) to indicate that the user wants to use the default RKE2 value.
# This means that all variables are optional, and the user can choose to override any value.
# When a user overrides a value, we use the validation block to ensure that the value is of the correct type and format.

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/root.go#L14
# Default: https://github.com/golang/go/blob/go1.20.5/src/sync/atomic/type.go#L35
variable "debug" {
  type        = string
  description = <<-EOT
    (Logging) Turn on debug logs.
    Defaults to false (Go default).
  EOT
  default     = ""
  # Boolean validation
  validation {
    condition     = (var.debug != "" ? can(regex("^(true|false)$", var.debug)) : true)
    error_message = "if specified, value must be 'true' or 'false'"
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L178
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L104
variable "bind-address" {
  type        = string
  description = <<-EOT
    (Listener) rke2 bind address.
    Defaults to '0.0.0.0'.
  EOT
  default     = ""
  # String IP address validation
  validation {
    condition = (
      var.bind-address != "" ? anytrue([
        can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.bind-address)),
        can(regex("^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$", var.bind-address)),
      ]) : true
    )
    error_message = "If an address is specified, it must be a valid IPv4 or IPv6 address."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L189
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/server/server.go#L241
variable "advertise-address" {
  type        = string
  description = <<-EOT
    (Listener) IPv4 address that apiserver uses to advertise to members of the cluster.
    Defaults to the external node address or the node address if external is not set.
  EOT
  default     = ""
  # String IP address validation
  validation {
    condition = (
      var.advertise-address != "" ? anytrue([
        can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.advertise-address)),
        can(regex("^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$", var.advertise-address)),
      ]) : true
    )
    error_message = "If an address is specified, it must be a valid IPv4 or IPv6 address."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L199
# Defaults(kubernetes): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/deps/deps.go#L429
# Defaults(localhost): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/server/server.go#L267
# Defaults(hostname): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/util/net.go#L162
variable "tls-san" {
  type        = string
  description = <<-EOT
    (Listener) Add additional hostnames or IPv4/IPv6 addresses as Subject Alternative Names on the server TLS cert.
    Defaults to "kubernetes", "kubernetes.default", "kubernetes.default.svc", "kubernetes.default.svc.cluster.local", "127.0.0.1","::1", "localhost", and your server's hostname.
    https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/
  EOT
  default     = ""
  # List hostname or ip validation
  validation {
    condition = (
      var.tls-san != "" ? alltrue([
        for s in split(",", var.tls-san) : anytrue([
          can(regex("^(?:[a-z0-9-]{1,63}\\.)+[a-z0-9-]{1,63}$", s)),
          can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", s)),
          can(regex("^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$", s)),
        ])
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid hostnames, IPv4, or IPv6 addresses."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L111
# Type override: https://github.com/rancher/rke2/blob/v1.27.3+rke2r1/pkg/cli/cmds/server.go#L49
# Default: https://github.com/rancher/rke2/blob/v1.27.3+rke2r1/pkg/cli/cmds/server.go#L15
variable "data-dir" {
  type        = string
  description = <<-EOT
    (Data) Folder to hold state.
    Defaults to "/var/lib/rancher/rke2"
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.data-dir != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.data-dir)) : true)
    error_message = "If specified, value must be a full file path."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L122
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L223
variable "cluster-cidr" {
  type        = string
  description = <<-EOT
    (Networking) IPv4/IPv6 network CIDRs to use for pod IPs.
    Defaults to "10.42.0.0/16".
  EOT
  default     = ""
  # List cidr validation
  validation {
    condition = (
      var.cluster-cidr != "" ? alltrue([
        for c in split(",", var.cluster-cidr) : can(cidrhost(c, 1))
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid CIDRs."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L127
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L228
variable "service-cidr" {
  type        = string
  description = <<-EOT
    (Networking) IPv4/IPv6 network CIDRs to use for service IPs.
    Defaults to "10.43.0.0/16".
  EOT
  default     = ""
  # List cidr validation
  validation {
    condition = (
      var.service-cidr != "" ? alltrue([
        for c in split(",", var.service-cidr) : can(cidrhost(c, 1))
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid CIDRs."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L132
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L136
variable "service-node-port-range" {
  type        = string
  description = <<-EOT
    (Networking) Port range to reserve for services with NodePort visibility.
    Defaults to "30000-32767".
  EOT
  default     = ""
  # String port range validation
  validation {
    condition     = (var.service-node-port-range != "" ? can(regex("[0-9]{1,5}-[0-9]{1,5}", var.service-node-port-range)) : true)
    error_message = "If specified, value must be a valid range."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L138
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L233
variable "cluster-dns" {
  type        = string
  description = <<-EOT
    (Networking) IPv4 Cluster IP for coredns service. Should be in your service-cidr range.
    Defaults to "10.43.0.10".
  EOT
  default     = ""
  # List ip validation
  validation {
    condition = (
      var.cluster-dns != "" ? alltrue([
        for c in split(",", var.cluster-dns) : anytrue([
          can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", c)),
          can(regex("^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$", c)),
        ])
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid IPv4 or IPv6 addresses."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L143
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L147
variable "cluster-domain" {
  type        = string
  description = <<-EOT
    (Networking) Cluster Domain.
    Defaults to "cluster.local".
  EOT
  default     = ""
  # String hostname validation
  validation {
    condition     = (var.cluster-domain != "" ? can(regex("^(?:[a-z0-9-]{1,63}\\.)+[a-z0-9-]{1,63}$", var.cluster-domain)) : true)
    error_message = "If specified, value must be a valid hostname."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L232
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L235
variable "egress-selector-mode" {
  type        = string
  description = <<-EOT
    (Networking) One of 'agent', 'cluster', 'pod', 'disabled'.
    Defaults to 'agent'.
  EOT
  default     = ""
  # String enum validation
  validation {
    condition     = (var.egress-selector-mode != "" ? can(regex("^(agent|cluster|pod|disabled)$", var.egress-selector-mode)) : true)
    error_message = "If specified, value must be one of 'agent', 'cluster', 'pod', 'disabled'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L238
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L241
variable "servicelb-namespace" {
  type        = string
  description = <<-EOT
    (Networking) Namespace of the pods for the servicelb component.
    Defaults to 'kube-system'.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.servicelb-namespace != "" ? can(regex("^[a-z0-9-]{1,253}$", var.servicelb-namespace)) : true)
    error_message = "If specified, value must be a valid namespace."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L243
# Default(directory): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/datadir/datadir.go#L16
# Default(path): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/server/server.go#L435
variable "write-kubeconfig" {
  type        = string
  description = <<-EOT
    (Client) Write kubeconfig for admin client to this file.
    Defaults to '/etc/rancher/rke2/rke2.yaml'.
  EOT
  default     = ""
  # File path validation
  validation {
    condition     = (var.write-kubeconfig != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.write-kubeconfig)) : true)
    error_message = "If specified, value must be a valid file path."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L249
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/server/server.go#L468
variable "write-kubeconfig-mode" {
  type        = string
  description = <<-EOT
    (Client) Write kubeconfig with this mode.
    Defaults to '0600'.
  EOT
  default     = ""
  # String file mode validation
  validation {
    condition     = (var.write-kubeconfig-mode != "" ? can(regex("^(?:0[0-7]{3})$", var.write-kubeconfig-mode)) : true)
    error_message = "If specified, value must be a valid octal for file mode, such as '0600' or '0755'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L116
# Default(call to generate): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/kubeadm/token.go#L45
# Default(generate): https://github.com/kubernetes/cluster-bootstrap/blob/v0.27.3/token/util/helpers.go#L45
# Default(random): https://github.com/kubernetes/cluster-bootstrap/blob/v0.27.3/token/util/helpers.go#L61
variable "token" {
  type        = string
  description = <<-EOT
    (Cluster) Shared secret used to join a server or agent to a cluster.
    If no token or token file is set, a random token will be generated.
  EOT
  default     = ""
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L256
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cluster/storage.go#L125
variable "token-file" {
  type        = string
  description = <<-EOT
    (Cluster) File containing the token.
    Defaults to "/var/lib/rancher/rke2/server/token".
    This is ignored if token is set. 
    If no token or token file is set, a random token will be generated.
  EOT
  default     = ""
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L262
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cluster/bootstrap.go#L440
variable "agent-token" {
  type        = string
  description = <<-EOT
    (Cluster) Shared secret used to join agents to the cluster, but not servers.
    Defaults to the value of token.
  EOT
  default     = ""
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L268
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/server/server.go#L396
variable "agent-token-file" {
  type        = string
  description = <<-EOT
    (Cluster) File containing the agent secret.
    Defaults to "/var/lib/rancher/rke2/server/agent-token".
    This is ignored if agent-token is set.
  EOT
  default     = ""
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L274
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/server/server.go#L115
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/server/server.go#L493
# Default(loopback): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/config/types.go#L258
variable "server" {
  type        = string
  description = <<-EOT
    (Cluster) Server to connect to, used to join a cluster.
    Defaults to bind address and management port, if not otherwise set "https://127.0.0.1:6443".
  EOT
  default     = ""
  # String URL validation
  validation {
    condition = (var.server != "" ? anytrue([
      can("^https?://(?:[a-z0-9-]{1,63}\\.)+[a-z0-9-]{1,63}(?::[0-9]{1,5})?$", var.server),
      can("^https?://(?:[0-9]{1,3}\\.){3}[0-9]{1,3}(?::[0-9]{1,5})?$", var.server),
      can("^https?://(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}(?::[0-9]{1,5})?$", var.server),
    ]) : true)
    error_message = "If specified, value must be a valid address starting with 'http(s)'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L286
# Default: https://github.com/golang/go/blob/go1.20.5/src/sync/atomic/type.go#L35
variable "cluster-reset" {
  type        = string
  description = <<-EOT
    (Cluster) Forget all peers and become sole member of a new cluster.
    Defaults to false (Go default).
  EOT
  default     = ""
  validation {
    condition     = (var.cluster-reset != "" ? can(regex("^(true|false)$", var.cluster-reset)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L292
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/etcd/etcd.go#L270
# Default(snapshot dir): https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/etcd/etcd.go#L1184
variable "cluster-reset-restore-path" {
  type        = string
  description = <<-EOT
    (Db) Path to snapshot file to be restored.
    This doesn't make sense without cluster-reset = true.
    Default snapshot path is "/var/lib/rancher/rke2/server/db/snapshots".
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.cluster-reset-restore-path != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.cluster-reset-restore-path)) : true)
    error_message = "If specified, value must be a valid file path starting with '/'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L149
# Default: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/daemons/control/server.go#L153
variable "kube-apiserver-arg" {
  type        = string
  description = <<-EOT
    (Flags) Customized flag for kube-apiserver process.
  EOT
  default     = ""
  # List of key=value validation
  validation {
    condition     = (var.kube-apiserver-arg != "" ? alltrue([for a in var.kube-apiserver-arg : can(regex("^.+=.+$", a))]) : true)
    error_message = "If specified, value must be a list of key=value pairs."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L154
variable "etcd-arg" {
  type        = string
  description = <<-EOT
    (Flags) Customized flag for etcd process.
  EOT
  default     = ""
  # List of key=value validation
  validation {
    condition     = (var.etcd-arg != "" ? alltrue([for a in var.etcd-arg : can(regex("^.+=.+$", a))]) : true)
    error_message = "If specified, value must be a list of key=value pairs."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L164
variable "kube-controller-manager-arg" {
  type        = string
  description = <<-EOT
    (Flags) Customized flag for kube-controller-manager process.
  EOT
  default     = ""
  # List of key=value validation
  validation {
    condition     = (var.kube-controller-manager-arg != "" ? alltrue([for a in var.kube-controller-manager-arg : can(regex("^.+=.+$", a))]) : true)
    error_message = "If specified, value must be a list of key=value pairs."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L159
variable "kube-scheduler-arg" {
  type        = string
  description = <<-EOT
    (Flags) Customized flag for kube-scheduler process.
  EOT
  default     = ""
  # List of key=value validation
  validation {
    condition     = (var.kube-scheduler-arg != "" ? alltrue([for a in var.kube-scheduler-arg : can(regex("^.+=.+$", a))]) : true)
    error_message = "If specified, value must be a list of key=value pairs."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L330
variable "etcd-expose-metrics" {
  type        = string
  description = <<-EOT
    (Db) Expose etcd metrics to client interface.
  EOT
  default     = ""
  validation {
    condition     = (var.etcd-expose-metrics != "" ? can(regex("^(true|false)$", var.etcd-expose-metrics)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L335
variable "etcd-disable-snapshots" {
  type        = string
  description = <<-EOT
    (Db) Disable automatic etcd snapshots.
  EOT
  default     = ""
  validation {
    condition     = (var.etcd-disable-snapshots != "" ? can(regex("^(true|false)$", var.etcd-disable-snapshots)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L340
variable "etcd-snapshot-name" {
  type        = string
  description = <<-EOT
    (Db) Set the base name of etcd snapshots.
    Defaults to 'etcd-snapshot'.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.etcd-snapshot-name != "" ? can(regex("^[a-z0-9-]{1,253}$", var.etcd-snapshot-name)) : true)
    error_message = "If specified, value must be a valid namespace."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L346
variable "etcd-snapshot-schedule-cron" {
  type        = string
  description = <<-EOT
    (Db) Snapshot interval time in cron spec. eg. every 5 hours '0 */5 * * *'.
    Defaults to '0 */12 * * *'.
  EOT
  default     = ""
  # String cron validation
  validation {
    condition     = (var.etcd-snapshot-schedule-cron != "" ? can(regex("^((\\*(\\/\\d+)?|,|[0-5]?[0-9](-[0-5]?[0-9])?(,[0-5]?[0-9](-[0-5]?[0-9])?)*)\\s){4}((\\*(\\/\\d+)?|,|[0-7](-[0-7])?(,[0-7](-[0-7])?)*))$", var.etcd-snapshot-schedule-cron)) : true)
    error_message = "If specified, value must be a valid cron expression."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L352
variable "etcd-snapshot-retention" {
  type        = string
  description = <<-EOT
    (Db) Number of snapshots to retain.
    Defaults to 5.
  EOT
  default     = ""
  # String number validation
  validation {
    condition     = (var.etcd-snapshot-retention != "" ? can(regex("^[0-9]+$", var.etcd-snapshot-retention)) : true)
    error_message = "If specified, value must be a valid number."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L358
variable "etcd-snapshot-dir" {
  type        = string
  description = <<-EOT
    (Db) Directory to save db snapshots.
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.etcd-snapshot-dir != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.etcd-snapshot-dir)) : true)
    error_message = "If specified, value must be a full file path."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L363
variable "etcd-snapshot-compress" {
  type        = string
  description = <<-EOT
    (Db) Compress etcd snapshot.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.etcd-snapshot-compress != "" ? can(regex("^(true|false)$", var.etcd-snapshot-compress)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L368
variable "etcd-s3" {
  type        = string
  description = <<-EOT
    (Db) Enable backup to S3.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.etcd-s3 != "" ? can(regex("^(true|false)$", var.etcd-s3)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L373
variable "etcd-s3-endpoint" {
  type        = string
  description = <<-EOT
    (Db) S3 endpoint url.
    Defaults to 's3.amazonaws.com'.
  EOT
  default     = ""
  # String domain validation
  validation {
    condition     = (var.etcd-s3-endpoint != "" ? can(regex("^(?:[a-z0-9-]{1,63}\\.)+[a-z0-9-]{1,63}$", var.etcd-s3-endpoint)) : true)
    error_message = "If specified, value must be a valid domain."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L379
variable "etcd-s3-endpoint-ca" {
  type        = string
  description = <<-EOT
    (Db) S3 custom CA cert to connect to S3 endpoint.
    Path to a PEM-encoded CA cert file to use to verify the S3 endpoint.
    This is only necessary if the S3 endpoint is using a custom CA.
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.etcd-s3-endpoint-ca != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.etcd-s3-endpoint-ca)) : true)
    error_message = "If specified, value must be a full file path."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L384
variable "etcd-s3-skip-ssl-verify" {
  type        = string
  description = <<-EOT
    (Db) Disables S3 SSL certificate validation.
  EOT
  default     = ""
  validation {
    condition     = (var.etcd-s3-skip-ssl-verify != "" ? can(regex("^(true|false)$", var.etcd-s3-skip-ssl-verify)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L389
variable "etcd-s3-access-key" {
  type        = string
  description = <<-EOT
    (Db) S3 access key id.
  EOT
  default     = ""
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L395
variable "etcd-s3-secret-key" {
  type        = string
  description = <<-EOT
    (Db) S3 secret access key.
  EOT
  default     = ""
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L401
variable "etcd-s3-bucket" {
  type        = string
  description = <<-EOT
    (Db) S3 bucket name.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.etcd-s3-bucket != "" ? can(regex("^[a-z0-9-]{1,253}$", var.etcd-s3-bucket)) : true)
    error_message = "If specified, value must be a valid namespace."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L406
variable "etcd-s3-region" {
  type        = string
  description = <<-EOT
    (Db) S3 region / bucket location.
    Defaults to us-east-1.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.etcd-s3-region != "" ? can(regex("^[a-z0-9-]{1,253}$", var.etcd-s3-region)) : true)
    error_message = "If specified, value must be a valid namespace."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L412
variable "etcd-s3-folder" {
  type        = string
  description = <<-EOT
    (Db) S3 folder.
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.etcd-s3-folder != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.etcd-s3-folder)) : true)
    error_message = "If specified, value must be a full file path."
  }
}

# Type: # Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L417
variable "etcd-s3-insecure" {
  type        = string
  description = <<-EOT
    (Db) Disables S3 over HTTPS.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.etcd-s3-insecure != "" ? can(regex("^(true|false)$", var.etcd-s3-insecure)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L422
variable "etcd-s3-timeout" {
  type        = string
  description = <<-EOT
    (Db) S3 timeout.
    Defaults to 5m.
  EOT
  default     = ""
  # String duration validation
  validation {
    condition     = (var.etcd-s3-timeout != "" ? can(regex("^[\\d]+[smh]$", var.etcd-s3-timeout)) : true)
    error_message = "If specified, value must be a string duration ([\\d]+[smh])."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L433
variable "disable" {
  type        = string
  description = <<-EOT
    (Components) Do not deploy packaged components and delete any deployed components.
  EOT
  default     = ""
  # List of k8s label validation
  validation {
    condition = (
      var.disable != "" ? alltrue([
        for c in split(",", var.disable) : can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", c))
      ]) : true
    )
    error_message = "If specified, value must be a comma separated list of components."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L437
variable "disable-scheduler" {
  type        = string
  description = <<-EOT
    (Components) Disable Kubernetes default scheduler.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.disable-scheduler != "" ? can(regex("^(true|false)$", var.disable-scheduler)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L442
variable "disable-cloud-controller" {
  type        = string
  description = <<-EOT
    (Components) Disable rke2 default cloud controller manager.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.disable-cloud-controller != "" ? can(regex("^(true|false)$", var.disable-cloud-controller)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L447
variable "disable-kube-proxy" {
  type        = string
  description = <<-EOT
    (Components) Disable running kube-proxy.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.disable-kube-proxy != "" ? can(regex("^(true|false)$", var.disable-kube-proxy)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L78
variable "node-name" {
  type        = string
  description = <<-EOT
    (Agent/node) Node name.
  EOT
  default     = ""
  # String hostname validation
  validation {
    condition     = (var.node-name != "" ? can(regex("^[a-zA-Z0-9-]{1,253}$", var.node-name)) : true)
    error_message = "If specified, value must be a valid hostname."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L84
variable "with-node-id" {
  type        = string
  description = <<-EOT
    (Agent/node) Append id to node name.
  EOT
  default     = ""
  validation {
    condition     = (var.with-node-id != "" ? can(regex("^(true|false)$", var.with-node-id)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L84
variable "node-label" {
  type        = string
  description = <<-EOT
    (Agent/node) Registering and starting kubelet with set of labels.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.node-label != "" ? alltrue([
      for label in split(",", var.node-label) :
      alltrue([for l in split("=", label) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", label))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of kubernetes labels (k/v)."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L184
variable "node-taint" {
  type        = string
  description = <<-EOT
    (Agent/node) Registering kubelet with set of taints.
  EOT
  default     = ""
  #List of k8s label validation
  validation {
    condition = (var.node-taint != "" ? alltrue([         # example=app:NoSchedule,ex=app:NoSchedule
      for taint in split(",", var.node-taint) : alltrue([ # example=app:NoSchedule
        for tp in split("=", taint) : alltrue([           # [0]=example,[1]=app:NoSchedule
          for tpp in split(":", tp) :                     # [0]example,[1]app,[2]NoSchedule
          can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", tpp))
        ])
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of kubernetes taints with effects (k=v:e)."
  }
}

variable "image-credential-provider-bin-dir" {
  type        = string
  description = <<-EOT
    (Agent/node) The path to the directory where credential provider plugin binaries are located.
  EOT
  default     = ""
  # String path validation
  validation {
    condition     = (var.image-credential-provider-bin-dir != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.image-credential-provider-bin-dir)) : true)
    error_message = "If specified, value must be a valid path."
  }
}

variable "image-credential-provider-config" {
  type        = string
  description = <<-EOT
    (Agent/node) The path to the credential provider plugin config file.
  EOT
  default     = ""
  # String path validation
  validation {
    condition     = (var.image-credential-provider-config != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.image-credential-provider-config)) : true)
    error_message = "If specified, value must be a valid path."
  }
}

variable "container-runtime-endpoint" {
  type        = string
  description = <<-EOT
    (Agent/runtime) Disable embedded containerd and use the CRI socket at the given path; when used with --docker this sets the docker socket path.
  EOT
  default     = ""
  # String path validation
  validation {
    condition     = (var.container-runtime-endpoint != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.container-runtime-endpoint)) : true)
    error_message = "If specified, value must be a valid path."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L135
variable "snapshotter" {
  type        = string
  description = <<-EOT
    (Agent/runtime) Override default containerd snapshotter.
  EOT
  default     = ""
  # String simple namespace validation
  validation {
    condition     = (var.snapshotter != "" ? can(regex("^[a-z0-9-]{1,253}$", var.snapshotter)) : true)
    error_message = "If specified, value must be a valid name."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L117
variable "private-registry" {
  type        = string
  description = <<-EOT
    (Agent/runtime) Private registry configuration file.
  EOT
  default     = ""
  # String path validation
  validation {
    condition     = (var.private-registry != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.private-registry)) : true)
    error_message = "If specified, value must be a valid path."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L491
variable "system-default-registry" {
  type        = string
  description = <<-EOT
    (Agent/runtime) Private registry to be used for all system images.
  EOT
  default     = ""
  # String domain validation
  validation {
    condition     = (var.system-default-registry != "" ? can(regex("^(?:[a-z0-9-]{1,63}\\.)+[a-z0-9-]{1,63}$", var.system-default-registry)) : true)
    error_message = "If specified, value must be a valid domain."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L68
variable "node-ip" {
  type        = string
  description = <<-EOT
    (Agent/networking) IPv4/IPv6 addresses to advertise for node.
  EOT
  default     = ""
  # List ip validation
  validation {
    condition = (
      var.node-ip != "" ? alltrue([
        for n in split(",", var.node-ip) : anytrue([
          can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", n)),
          can(regex("^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$", n)),
        ])
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid IPv4 or IPv6 addresses."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L73
variable "node-external-ip" {
  type        = string
  description = <<-EOT
    (Agent/networking) IPv4/IPv6 external IP addresses to advertise for node.
  EOT
  default     = ""
  # List ip validation
  validation {
    condition = (
      var.node-external-ip != "" ? alltrue([
        for n in split(",", var.node-external-ip) : anytrue([
          can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", n)),
          can(regex("^(?:[0-9a-f]{0,4}:{1,7}){1,7}[0-9a-f]{0,4}$", n)),
        ])
      ]) : true
    )
    error_message = "If specified, value must be a comma-separated list of valid IPv4 or IPv6 addresses."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L168
variable "resolv-conf" {
  type        = string
  description = <<-EOT
    (Agent/networking) Kubelet resolv.conf file.
  EOT
  default     = ""
  # String path validation
  validation {
    condition     = (var.resolv-conf != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.resolv-conf)) : true)
    error_message = "If specified, value must be a valid path."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L174
variable "kubelet-arg" {
  type        = string
  description = <<-EOT
    (Agent/flags) Customized flag for kubelet process.
  EOT
  default     = ""
  # List kubernetes label validation
  validation {
    condition = (var.kubelet-arg != "" ? alltrue([ # arg1=val1,arg2=val2
      for arg in split(",", var.kubelet-arg) :     # arg1=val1
      alltrue([for a in split("=", arg) :          # [0]=arg1, [1]=val1
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", a))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of args (k/v)."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L179
variable "kube-proxy-arg" {
  type        = string
  description = <<-EOT
    (Agent/flags) Customized flag for kube-proxy process.
  EOT
  default     = ""
  # List kubernetes label validation
  validation {
    condition = (var.kube-proxy-arg != "" ? alltrue([ # arg1=val1,arg2=val2
      for arg in split(",", var.kube-proxy-arg) :     # arg1=val1
      alltrue([for a in split("=", arg) :             # [0]=arg1, [1]=val1
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", a))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of args (k/v)."
  }
}

# Type: https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L89
variable "protect-kernel-defaults" {
  type        = string
  description = <<-EOT
    (Agent/node) Kernel tuning behavior. If set, error if kernel tunables are different than kubelet defaults.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.protect-kernel-defaults != "" ? can(regex("^(true|false)$", var.protect-kernel-defaults)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/server.go#L515
variable "enable-pprof" {
  type        = string
  description = <<-EOT
    (Experimental) Enable pprof endpoint on supervisor port.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.enable-pprof != "" ? can(regex("^(true|false)$", var.enable-pprof)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L94
variable "selinux" {
  type        = string
  description = <<-EOT
    (Agent/node) Enable SELinux in containerd.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.selinux != "" ? can(regex("^(true|false)$", var.selinux)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# https://github.com/k3s-io/k3s/blob/v1.27.3%2Bk3s1/pkg/cli/cmds/agent.go#L100
variable "lb-server-port" {
  type        = string
  description = <<-EOT
    (Agent/node) Local port for supervisor client load-balancer.
    If the supervisor and apiserver are not colocated an 
    additional port 1 less than this port will also be used for the 
    apiserver client load-balancer.
  EOT
  default     = ""
  # String port validation
  validation {
    condition     = (var.lb-server-port != "" ? can(regex("^[0-9]{1,5}$", var.lb-server-port)) : true)
    error_message = "If specified, value must be a valid port number."
  }
}

# https://github.com/rancher/rke2/blob/v1.27.3%2Brke2r1/pkg/cli/cmds/server.go#L24
variable "cni" {
  type        = string
  description = <<-EOT
    (Networking) CNI Plugins to deploy, one of 'none, calico, canal, cilium'; 
    optionally with multus as the first value to enable the multus meta-plugin.
  EOT
  default     = ""
  # List validation
  validation {
    condition     = (var.cni != "" ? can(regex("^(none|calico|canal|cilium|multus,calico|multus,canal|multus,cilium)$", var.cni)) : true)
    error_message = "If specified, value must be one of 'none, calico, canal, cilium'; optionally with multus as the first value to enable the multus meta-plugin."
  }
}

# https://github.com/rancher/rke2/blob/v1.27.3%2Brke2r1/pkg/cli/cmds/server.go#L30
variable "enable-servicelb" {
  type        = string
  description = <<-EOT
    (Components) Enable rke2 default cloud controller manager's service controller.
  EOT
  default     = ""
  # String boolean validation
  validation {
    condition     = (var.enable-servicelb != "" ? can(regex("^(true|false)$", var.enable-servicelb)) : true)
    error_message = "If specified, value must be 'true' or 'false'."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L19
variable "kube-apiserver-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for kube-apiserver.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.kube-apiserver-image != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.kube-apiserver-image)) : true)
    error_message = "If specified, value must be a valid image name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L25
variable "kube-controller-manager-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for kube-controller-manager.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.kube-controller-manager-image != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.kube-controller-manager-image)) : true)
    error_message = "If specified, value must be a valid image name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L32
variable "cloud-controller-manager-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for cloud-controller-manager.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.cloud-controller-manager-image != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.cloud-controller-manager-image)) : true)
    error_message = "If specified, value must be a valid image name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L37
variable "kube-proxy-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for kube-proxy.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.kube-proxy-image != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.kube-proxy-image)) : true)
    error_message = "If specified, value must be a valid image name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L43
variable "kube-scheduler-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for kube-scheduler.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.kube-scheduler-image != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.kube-scheduler-image)) : true)
    error_message = "If specified, value must be a valid image name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L49
variable "pause-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for pause.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.pause-image != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.pause-image)) : true)
    error_message = "If specified, value must be a valid image name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L55
variable "runtime-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for runtime binaries.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.runtime-image != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.runtime-image)) : true)
    error_message = "If specified, value must be a valid image name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L61
variable "etcd-image" {
  type        = string
  description = <<-EOT
    (Image) Override image to use for etcd.
  EOT
  default     = ""
  # String namespace validation
  validation {
    condition     = (var.etcd-image != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.etcd-image)) : true)
    error_message = "If specified, value must be a valid image name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L67
variable "kubelet-path" {
  type        = string
  description = <<-EOT
    (Experimental/agent) Override kubelet binary path.
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.kubelet-path != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.kubelet-path)) : true)
    error_message = "If specified, value must be a valid file path."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L73
variable "cloud-provider-name" {
  type        = string
  description = <<-EOT
    (Cloud provider) Cloud provider name.
  EOT
  default     = ""
  # String simple namespace validation
  validation {
    condition     = (var.cloud-provider-name != "" ? can(regex("^[a-z0-9-]{1,253}$", var.cloud-provider-name)) : true)
    error_message = "If specified, value must be a valid name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L80
variable "cloud-provider-config" {
  type        = string
  description = <<-EOT
    (Cloud provider) Cloud provider configuration file path.
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.cloud-provider-config != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.cloud-provider-config)) : true)
    error_message = "If specified, value must be a valid file path."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L85
# https://github.com/rancher/rke2/blob/master/pkg/rke2/rke2.go#L66
variable "profile" {
  type        = string
  description = <<-EOT
    (Security) Validate system configuration against the selected benchmark.
    Defaults to 'cis-1.23'.
  EOT
  default     = ""
  # String label validation
  validation {
    condition     = (var.profile != "" ? can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", var.profile)) : true)
    error_message = "If specified, value must be a valid name."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L90
variable "audit-policy-file" {
  type        = string
  description = <<-EOT
    (Security) Path to the file that defines the audit policy configuration.
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.audit-policy-file != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.audit-policy-file)) : true)
    error_message = "If specified, value must be a valid file path."
  }
}
# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L96
variable "pod-security-admission-config-file" {
  type        = string
  description = <<-EOT
    (Security) Path to the file that defines Pod Security Admission configuration.
  EOT
  default     = ""
  # String file path validation
  validation {
    condition     = (var.pod-security-admission-config-file != "" ? can(regex("^/(?:[a-zA-Z0-9_.-]+[/]?)+$", var.pod-security-admission-config-file)) : true)
    error_message = "If specified, value must be a valid file path."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L102
variable "control-plane-resource-requests" {
  type        = string
  description = <<-EOT
    (Components) Control Plane resource requests.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.control-plane-resource-requests != "" ? alltrue([
      for req in split(",", var.control-plane-resource-requests) :
      alltrue([for r in split("=", req) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", r))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L108
variable "control-plane-resource-limits" {
  type        = string
  description = <<-EOT
    (Components) Control Plane resource limits.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.control-plane-resource-limits != "" ? alltrue([
      for limit in split(",", var.control-plane-resource-limits) :
      alltrue([for l in split("=", limit) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", l))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L114
variable "control-plane-probe-configuration" {
  type        = string
  description = <<-EOT
    (Components) Control Plane Probe configuration.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.control-plane-probe-configuration != "" ? alltrue([
      for probe in split(",", var.control-plane-probe-configuration) :
      alltrue([for p in split("=", probe) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", p))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L120
variable "kube-apiserver-extra-mount" {
  type        = string
  description = <<-EOT
    (Components) kube-apiserver extra volume mounts.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.kube-apiserver-extra-mount != "" ? alltrue([
      for mount in split(",", var.kube-apiserver-extra-mount) :
      alltrue([for m in split("=", mount) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", m))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L126
variable "kube-scheduler-extra-mount" {
  type        = string
  description = <<-EOT
    (Components) kube-scheduler extra volume mounts.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.kube-scheduler-extra-mount != "" ? alltrue([
      for mount in split(",", var.kube-scheduler-extra-mount) :
      alltrue([for m in split("=", mount) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", m))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L132
variable "kube-controller-manager-extra-mount" {
  type        = string
  description = <<-EOT
    (Components) kube-controller-manager extra volume mounts.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.kube-controller-manager-extra-mount != "" ? alltrue([
      for mount in split(",", var.kube-controller-manager-extra-mount) :
      alltrue([for m in split("=", mount) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", m))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L138
variable "kube-proxy-extra-mount" {
  type        = string
  description = <<-EOT
    (Components) kube-proxy extra volume mounts.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.kube-proxy-extra-mount != "" ? alltrue([
      for mount in split(",", var.kube-proxy-extra-mount) :
      alltrue([for m in split("=", mount) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", m))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L144
variable "etcd-extra-mount" {
  type        = string
  description = <<-EOT
    (Components) etcd extra volume mounts.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.etcd-extra-mount != "" ? alltrue([
      for mount in split(",", var.etcd-extra-mount) :
      alltrue([for m in split("=", mount) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", m))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }

}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L150
variable "cloud-controller-manager-extra-mount" {
  type        = string
  description = <<-EOT
    (Components) cloud-controller-manager extra volume mounts.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.cloud-controller-manager-extra-mount != "" ? alltrue([
      for mount in split(",", var.cloud-controller-manager-extra-mount) :
      alltrue([for m in split("=", mount) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", m))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L156
variable "kube-apiserver-extra-env" {
  type        = string
  description = <<-EOT
    (Components) kube-apiserver extra environment variables.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.kube-apiserver-extra-env != "" ? alltrue([
      for env in split(",", var.kube-apiserver-extra-env) :
      alltrue([for e in split("=", env) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", e))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L162
variable "kube-scheduler-extra-env" {
  type        = string
  description = <<-EOT
    (Components) kube-scheduler extra environment variables.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.kube-scheduler-extra-env != "" ? alltrue([
      for env in split(",", var.kube-scheduler-extra-env) :
      alltrue([for e in split("=", env) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", e))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L168
variable "kube-controller-manager-extra-env" {
  type        = string
  description = <<-EOT
    (Components) kube-controller-manager extra environment variables.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.kube-controller-manager-extra-env != "" ? alltrue([
      for env in split(",", var.kube-controller-manager-extra-env) :
      alltrue([for e in split("=", env) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", e))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }

}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L174
variable "kube-proxy-extra-env" {
  type        = string
  description = <<-EOT
    (Components) kube-proxy extra environment variables.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.kube-proxy-extra-env != "" ? alltrue([
      for env in split(",", var.kube-proxy-extra-env) :
      alltrue([for e in split("=", env) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", e))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L180
variable "etcd-extra-env" {
  type        = string
  description = <<-EOT
    (Components) etcd extra environment variables.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.etcd-extra-env != "" ? alltrue([
      for env in split(",", var.etcd-extra-env) :
      alltrue([for e in split("=", env) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", e))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}

# https://github.com/rancher/rke2/blob/master/pkg/cli/cmds/root.go#L186
variable "cloud-controller-manager-extra-env" {
  type        = string
  description = <<-EOT
    (Components) cloud-controller-manager extra environment variables.
  EOT
  default     = ""
  # List of k8s labels validation
  validation {
    condition = (var.cloud-controller-manager-extra-env != "" ? alltrue([
      for env in split(",", var.cloud-controller-manager-extra-env) :
      alltrue([for e in split("=", env) :
        can(regex("^[a-zA-Z0-9.]{1,63}[/]?(?:[a-zA-Z0-9]{1,63}[-_.])*[a-zA-Z0-9.]{1,63}$", e))
      ])
      ]) : true
    )
    error_message = "If specified, value must be a valid comma separated list of key=value."
  }
}
