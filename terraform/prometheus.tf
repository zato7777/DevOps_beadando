resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name = "prometheus-config"
  }

  data = {
    "prometheus.yml" = <<EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'backend-nodejs'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['backend-service:5000']
EOF
  }
}

resource "kubernetes_deployment" "prometheus" {
    metadata {
        name = "prometheus-deployment"
        labels = {
            app = "prometheus"
        }
    }

    spec {
        replicas = 1
        selector {
            match_labels = {
                app = "prometheus"
            }
        }
        template {
            metadata {
                labels = {
                    app = "prometheus"
                }
            }

            spec {
                container {
                    name  = "prometheus"
                    image = "prom/prometheus:latest"
                    args = ["--config.file=/etc/prometheus/prometheus.yml"]
          
                    port {
                        container_port = 9090
                    }

                    volume_mount {
                        name = "config-volume"
                        mount_path = "/etc/prometheus/"
                    }
                }
                volume {
                    name = "config-volume"
                    config_map {
                        name = "prometheus-config"
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "prometheus" {
    metadata {
        name = "prometheus-service"
    }
    spec {
        selector = {
            app = "prometheus"
        }
        port {
            port        = 9090
            target_port = 9090
        }
    type = "NodePort"
    }
}