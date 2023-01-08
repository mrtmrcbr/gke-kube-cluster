resource "google_compute_network" "main" {
  name                            = "t-main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  mtu                             = 1460
}

resource "google_compute_subnetwork" "private" {
  name                     = "t-private"
  ip_cidr_range            = "10.0.0.0/16"
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pod-range"
    ip_cidr_range = "10.10.0.0/24"
  }
  secondary_ip_range {
    range_name    = "gke-service-range"
    ip_cidr_range = "10.20.0.0/24"
  }
}

resource "google_compute_router" "router" {
  name    = "t-router"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "nat" {
  name   = "t-nat"
  router = google_compute_router.router.name
  region = var.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat_ip.self_link]
}

resource "google_compute_address" "nat_ip" {
  name         = "t-nat-ip"
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "t-allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}