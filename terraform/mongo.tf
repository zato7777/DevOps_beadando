resource "kubernetes_persistent_volume_claim" "mongo_pvc" {
  metadata {
    name = "mongo-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "mongo" {
  metadata {
    name = "mongo"
    labels = {
      app = "mongo"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mongo"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }
      spec {
        container {
          image = "mongo:latest"
          name  = "mongo"
          port {
            container_port = 27017
          }

          volume_mount {
            name = "mongo-storage"
            mount_path = "/data/db"
          }
        }
        
        volume {
            name = "mongo-storage"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.mongo_pvc.metadata.0.name
            }
          }
      }
    }
  }
}

resource "kubernetes_service" "mongo" {
  metadata {
    name = "mongo-service"
  }
  spec {
    selector = {
      app = "mongo"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}