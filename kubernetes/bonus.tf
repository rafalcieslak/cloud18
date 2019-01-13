provider "google" {
  project = "rcieslak-182820"
  region = "europe-west3"
}


resource "google_container_cluster" "cluster" {
  name               = "cluster-demo"
  zone               = "europe-west1-c"
  initial_node_count = 3

  node_config {
    machine_type = "f1-micro"
    disk_size_gb = 10
    image_type   = "COS"
  }

 node_version = "1.8.4-gke.0"
 min_master_version= "1.8.4-gke.0"
}


provider "kubernetes" {
  host       = "https://${google_container_cluster.cluster.endpoint}"
  client_key = "${base64decode(google_container_cluster.cluster.master_auth.0.client_key)}"

  client_certificate     = "${base64decode(google_container_cluster.cluster.master_auth.0.client_certificate)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)}"
}

resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-pod"
    labels {
      app = "nginx"
    }
  }

  spec {
    container {
      image = "nginx:1.8"
      name  = "nginx"
      
      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }
  
  spec {
    selector {
      app = "${kubernetes_pod.nginx.metadata.0.labels.app}"
    }
    
    port {
      port = 8000
      target_port = 80
    }
    
    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = "${kubernetes_service.nginx.load_balancer_ingress.0.ip}"
}
