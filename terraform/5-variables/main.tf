provider "google" {
  project = "ii-cloud2018-demos"
  region = "europe-west3"
}


variable "server_size" {
  description = "The size of the server instance. Can be small, medium or large"
}

locals {
  a_local_variable = 42
  another_local_variable = "test"

  server_types_map = {
    "small"  = "f1-micro"
    "medium" = "n1-standard-2"
    "large"  = "n1-highcpu-64"
  }
}




resource "google_compute_address" "public_ip" {
  name         = "server-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "main_server" {
  name         = "server"
  machine_type = "${lookup(local.server_types_map, var.server_size)}"
  zone         = "europe-west3-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.public_ip.address}"
    }
  }

  tags = ["http-server"]

  metadata {
    sshKeys = "cielak:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVFpY12c9/oj9TUxsKc8b24txsTCtHV7+p3qJUHlxA8iD6a9WUN28JfGT3Kp9wBLOnOklKUqunUmfBTJF5fkpTlfsXQ8TFfVCahbJI81Lu2mp3lKjEsOKYFHMEVUzxt3WmKLpWMX0P0T9tcAQ92iej2UOcLvPMDNnM3TlXUKNh0g04fIvjmZqEClwC+QoXMYIG/+YZAA/7n6uO7JpHUifbSiKxMadhohtFWQF1SIWh0heG/uhmJlxBhePpii9niwPaiId5LXp/07aPlpRDuytsGbxbvucpIlQ/Xbgb0qNEuGLfssynLr9M7laoKBbEGta86HCnF9gBO1yLmEe05XN5"
  }
}

output "server_ip_address" {
  value = "${google_compute_address.public_ip.address}"
}
