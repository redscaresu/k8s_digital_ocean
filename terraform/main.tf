variable "do_token" {}


provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  load_config_file = false
  host  = digitalocean_kubernetes_cluster.production.endpoint
  token = digitalocean_kubernetes_cluster.production.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.production.kube_config[0].cluster_ca_certificate
  )
}

resource "digitalocean_kubernetes_cluster" "production" {
  name    = "production"
  region  = "ams3"
  version = "1.16.6-do.2"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 1
  }
}

output "kubeconfig" {
  value = digitalocean_kubernetes_cluster.production.kube_config[0].token
}

output "host" {
  value = digitalocean_kubernetes_cluster.production.endpoint
}

output "cluster_ca_certificate" {
  value = base64decode(digitalocean_kubernetes_cluster.production.kube_config[0].cluster_ca_certificate)
}
