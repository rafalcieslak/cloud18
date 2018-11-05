provider "google" {
  project = "ii-cloud2018-demos"
  region = "europe-west3"
}


resource "google_compute_address" "public_ip" {
  count = 3
  
  name         = "server-ip-${count.index}"
  address_type = "EXTERNAL"
}
