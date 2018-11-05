provider "google" {
  project = "ii-cloud2018-demos"
  region = "europe-west3"

  # export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials/file.json
}

resource "google_compute_instance" "main_server" {
  name         = "myserver"
  machine_type = "f1-micro"
  zone         = "europe-west3-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Empty to generate a temporary public IP
    }
  }

  tags = ["http-server", "another-tag"]

  metadata {
    sshKeys = "cielak:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVFpY12c9/oj9TUxsKc8b24txsTCtHV7+p3qJUHlxA8iD6a9WUN28JfGT3Kp9wBLOnOklKUqunUmfBTJF5fkpTlfsXQ8TFfVCahbJI81Lu2mp3lKjEsOKYFHMEVUzxt3WmKLpWMX0P0T9tcAQ92iej2UOcLvPMDNnM3TlXUKNh0g04fIvjmZqEClwC+QoXMYIG/+YZAA/7n6uO7JpHUifbSiKxMadhohtFWQF1SIWh0heG/uhmJlxBhePpii9niwPaiId5LXp/07aPlpRDuytsGbxbvucpIlQ/Xbgb0qNEuGLfssynLr9M7laoKBbEGta86HCnF9gBO1yLmEe05XN5"
  }
}

output "server_instance_name" {
  value = "${google_compute_instance.main_server.name}"
}

output "server_ip_address" {
  value = "${google_compute_instance.main_server.network_interface.0.access_config.0.assigned_nat_ip}"
}
