provider "google" {
  project = "ii-cloud2018-demos"
  region = "europe-west3"
}

resource "google_compute_network" "main_network" {
  name = "main"
}

resource "google_compute_subnetwork" "http-servers" {
  name          = "servers"
  ip_cidr_range = "10.111.5.0/24"
  network       = "${google_compute_network.main_network.self_link}"
}

resource "google_sql_database_instance" "main-db" {
  name             = "main-db-instance"
  database_version = "MYSQL_5_6"
  region           = "europe-west3"

  settings {
    tier            = "db-f1-micro"
    disk_autoresize = "true"
  }
}

resource "google_sql_database" "users" {
  instance  = "${google_sql_database_instance.main-db.name}"
  name      = "users-database"
}

resource "google_sql_user" "machine-user" {
  instance  = "${google_sql_database_instance.main-db.name}"
  name      = "databaseuser"
  password  = "thisismypasswordpleasechangeme"
  host      = "${google_compute_instance.main_server.name}"
}

resource "google_compute_address" "public_ip" {
  name         = "server-ip"
  address_type = "EXTERNAL"
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
    subnetwork = "${google_compute_subnetwork.http-servers.self_link}"

    access_config {
      nat_ip = "${google_compute_address.public_ip.address}"
    }
  }

  tags = ["http-server"]

  metadata {
    sshKeys = "cielak:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVFpY12c9/oj9TUxsKc8b24txsTCtHV7+p3qJUHlxA8iD6a9WUN28JfGT3Kp9wBLOnOklKUqunUmfBTJF5fkpTlfsXQ8TFfVCahbJI81Lu2mp3lKjEsOKYFHMEVUzxt3WmKLpWMX0P0T9tcAQ92iej2UOcLvPMDNnM3TlXUKNh0g04fIvjmZqEClwC+QoXMYIG/+YZAA/7n6uO7JpHUifbSiKxMadhohtFWQF1SIWh0heG/uhmJlxBhePpii9niwPaiId5LXp/07aPlpRDuytsGbxbvucpIlQ/Xbgb0qNEuGLfssynLr9M7laoKBbEGta86HCnF9gBO1yLmEe05XN5"
  }
}
