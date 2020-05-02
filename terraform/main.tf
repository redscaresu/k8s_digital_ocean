variable "do_token" {}
variable "spaces_access_id" {}
variable "spaces_secret_key" {}


provider "digitalocean" {
  token = var.do_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}

terraform {
  backend "s3" {
    endpoint = "https://space4.ams3.digitaloceanspaces.com/"
    region = "us-west-1"
    key = "terraform.tfstate"
    bucket = "terrform_state_production"
    skip_credentials_validation = true
    skip_metadata_api_check = true
  }
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
  value = digitalocean_kubernetes_cluster.production.kube_config[0].raw_config
}
