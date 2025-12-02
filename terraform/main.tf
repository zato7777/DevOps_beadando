terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

variable "kube_config" {
    type = string
}

provider "kubernetes" {
    config_path = var.kube_config
}
