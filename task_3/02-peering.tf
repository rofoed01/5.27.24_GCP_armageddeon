resource "google_compute_network_peering" "peering_eu_americas" {
  name         = "peering-eu-to-americas"
  network      = google_compute_network.vpc_eu.self_link
  peer_network = google_compute_network.vpc_americas.self_link

  import_custom_routes = true
  export_custom_routes = true

  depends_on = [ 
    google_compute_network.vpc_eu,
    google_compute_network.vpc_americas,
    google_compute_subnetwork.vpc-eu-subnet,
    google_compute_subnetwork.vpc-americas-NA,
    google_compute_subnetwork.vpc-americas-SA
   ]
}

resource "google_compute_network_peering" "peering_americas_eu" {
  name         = "peering-americas-to-eu"
  network      = google_compute_network.vpc_americas.self_link
  peer_network = google_compute_network.vpc_eu.self_link

  import_custom_routes = true
  export_custom_routes = true

  depends_on = [ 
    google_compute_network.vpc_eu,
    google_compute_network.vpc_americas,
    google_compute_subnetwork.vpc-eu-subnet,
    google_compute_subnetwork.vpc-americas-NA,
    google_compute_subnetwork.vpc-americas-SA
   ]
}