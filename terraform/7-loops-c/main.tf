provider "google" {
  project = "ii-cloud2018-demos"
  region = "europe-west3"
}

data "google_compute_zones" "available" {}

locals {
  zones = ["${data.google_compute_zones.available.names}"]
}

output "zones_available" {
  value = ["${local.zones}"]
}



resource "google_compute_address" "public_ip" {
  count = "${length(local.zones)}"

  name         = "server-ip-${count.index}"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "server" {
  count = "${length(local.zones)}"

  name         = "myserver-${count.index}"
  machine_type = "f1-micro"
  zone         = "${element(local.zones, count.index)}"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${element(google_compute_address.public_ip.*.address, count.index)}"
    }
  }
}


output "server_ips" {
  value = "${google_compute_address.public_ip.*.address}"
}
