variable "environment_name" {
  description = "Environment name to use for naming resources."
}

variable "main_server_type" {
  description = "Server type to use for the main application server."
  default     = "g1-micro"
}


resource "google_compute_address" "public_ip" {
  name         = "${var.environment_name}-server-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "main_server" {
  name         = "${var.environment_name}-server"
  machine_type = "${var.main_server_type}"
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
}

resource "google_storage_bucket" "data-bucket" {
  name = "example-application-data-bucket-${var.environment_name}"
}

resource "google_storage_bucket_acl" "data-bucket-acl" {
  bucket         = "${google_storage_bucket.data-bucket.name}"
  predefined_acl = "projectprivate"
}

/* Many other resources! */

output "server_ip" {
  value = "${google_compute_address.public_ip.address}"
}

output "bucket_name" {
  value = "${google_storage_bucket.data-bucket.name}"
}
