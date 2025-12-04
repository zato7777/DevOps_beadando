resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"
    labels = {
      app = "backend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        init_container {
          name = "wait-for-mongo"
          image = "busybox:1.28"
          command = [
            "sh", 
            "-c", 
            "until nc -z mongo-service 27017; do echo 'Várakozás a Mongora...'; sleep 2; done;"
          ]
        }
        
        container {
          image = "zato7777/jegy-backend:latest" 
          name  = "backend"
          
          port {
            container_port = 5000
          }

          env {
            name  = "DB_URL"
            value = "mongodb://mongo-service:27017/jegyertekesito"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend-service"
  }
  spec {
    selector = {
      app = "backend"
    }

    type = "NodePort"

    port {
      port        = 5000
      target_port = 5000
      node_port = 30001
    }
  }
}