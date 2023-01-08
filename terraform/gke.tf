module "gke_private_cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "24.1.0"

  name       = "t-gke-private-cluster"
  project_id = var.project
  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.private.name
  regional   = false
  zones      = [var.zone]

  node_pools = [
    {
      name         = "t-gke-node-pool"
      machine_type = "e2-small"
    }
  ]

  enable_private_nodes = true
  ip_range_pods        = "gke-pod-range"
  ip_range_services    = "gke-service-range"
  master_ipv4_cidr_block = "172.16.0.0/28"

}