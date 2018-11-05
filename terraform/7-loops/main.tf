provider "google" {
  project = "ii-cloud2018-demos"
  region = "europe-west3"
}


resource "google_compute_address" "public_ip_1" {
  name         = "server-ip-1"
  address_type = "EXTERNAL"
}
resource "google_compute_address" "public_ip_2" {
  name         = "server-ip-2"
  address_type = "EXTERNAL"
}
resource "google_compute_address" "public_ip_3" {
  name         = "server-ip-3"
  address_type = "EXTERNAL"
}


resource "google_compute_instance" "server_1" {
  name         = "myserver-1"
  machine_type = "f1-micro"
  zone         = "europe-west3-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    access_config {
      nat_ip = "${google_compute_address.public_ip_1.address}"
    }
  }
}
resource "google_compute_instance" "server_2" {
  name         = "myserver-2"
  machine_type = "f1-micro"
  zone         = "europe-west3-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.public_ip_2.address}"
    }
  }
}
resource "google_compute_instance" "server_3" {
  name         = "myserver-3"
  machine_type = "f1-micro"
  zone         = "europe-west3-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    access_config {
      nat_ip = "${google_compute_address.public_ip_3.address}"
    }
  }
}


output "server_ip_addresses" {
  value = [
    "${google_compute_address.public_ip_1.address}",
    "${google_compute_address.public_ip_2.address}",
    "${google_compute_address.public_ip_3.address}"
  ]
}
