resource "kubernetes_persistent_volume_claim" "grafana_pvc" {
    metadata {
        name = "grafana-pvc"
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

resource "kubernetes_deployment" "grafana" {
    metadata {
        name = "grafana-deployment"
        labels = {
            app = "grafana"
        }
    }

    spec {
        replicas = 1
        selector {
            match_labels = {
                app = "grafana"
            }
        }
        template {
            metadata {
                labels = {
                    app = "grafana"
                }
            }
            spec {
                security_context {
                    fs_group    = 472
                    run_as_user = 472
                }

                container {
                    name  = "grafana"
                    image = "grafana/grafana:latest"

                    port {
                        container_port = 3000
                    }

                    volume_mount {
                        mount_path = "/var/lib/grafana"
                        name       = "grafana-storage"
                    }
                }

                volume {
                    name = "grafana-storage"
                    persistent_volume_claim {
                        claim_name = "grafana-pvc"
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "grafana" {
    metadata {
        name = "grafana-service"
    }
    spec {
        selector = {
            app = "grafana"
        }

        type = "NodePort"

        port {
            port        = 3000
            target_port = 3000
            node_port   = 30002
        }
    }
}