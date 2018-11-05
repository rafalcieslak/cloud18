variable "environment_name" {
  description = "Environment name to use for naming resources."
}

variable "main_server_type" {
  description = "Server type to use for the main application server."
  default     = "g1-micro"
}

variable "needs_database" {
  description = "Please set this to true for environments that need a database."
  default     = "false"
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

  provisioner "local-exec" {
    command = <<EOF
      ansible-playbook playbook.yml \
                   -e server_ip=${google_compute_address.public_ip.address} \
                   -e enable_database=${var.needs_database}"
EOF
  }
}

resource "google_storage_bucket" "data-bucket" {
  name = "example-application-data-bucket-${var.environment_name}"
}

resource "google_storage_bucket_acl" "data-bucket-acl" {
  bucket         = "${google_storage_bucket.data-bucket.name}"
  predefined_acl = "projectprivate"
}

###### DATABASE ######

resource "google_sql_database_instance" "main-db" {
  count = "${var.needs_database ? 1 : 0}"

  name             = "main-db-instance"
  database_version = "MYSQL_5_6"
  region           = "europe-west3"

  settings {
    tier            = "db-f1-micro"
    disk_autoresize = "true"
  }
}

resource "google_sql_database" "users" {
  count = "${var.needs_database ? 1 : 0}"

  instance  = "${google_sql_database_instance.main-db.name}"
  name      = "users-database"
}

resource "google_sql_user" "machine-user" {
  count = "${var.needs_database ? 1 : 0}"

  instance  = "${google_sql_database_instance.main-db.name}"
  name      = "databaseuser"
  password  = "thisismypasswordpleasechangeme"
  host      = "${google_compute_instance.main_server.name}"
}



/* Many other resources! */

output "server_ip" {
  value = "${google_compute_address.public_ip.address}"
}

output "bucket_name" {
  value = "${google_storage_bucket.data-bucket.name}"
}
