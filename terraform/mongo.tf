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
    selector {
      app = "mongo"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}