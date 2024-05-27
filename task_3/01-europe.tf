resource "google_compute_network" "vpc_eu" {
  name = "eu-${random_id.rng.hex}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "vpc-eu-subnet" {
  name = "euwest-${google_compute_network.vpc_eu.name}"
  network = google_compute_network.vpc_eu.self_link
  ip_cidr_range = "10.18.1.0/24" 
  region = "europe-west1"
  private_ip_google_access = "true"

  depends_on = [ 
    google_compute_network.vpc_eu, 
    google_compute_firewall.vpc_eu_firewall
    ]
}

resource "google_compute_firewall" "vpc_eu_firewall" {
  name    = "${google_compute_network.vpc_eu.name}-rules"
  network = google_compute_network.vpc_eu.self_link
  direction = "INGRESS"
  source_ranges = ["172.20.18.0/24", "172.30.18.0/24", "192.168.18.0/24"]
  
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  allow {
    protocol = "icmp"
  }
  
  target_tags = ["eu", "ssh-server", "rdp-server"]
  
}

resource "google_compute_instance" "vm-eu" {
  name         = "vm-${google_compute_network.vpc_eu.name}"
  description = "Instance created by Terraform, using the google provider, for VPC ${google_compute_network.vpc_eu.self_link}"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_eu.self_link
    subnetwork = google_compute_subnetwork.vpc-eu-subnet.self_link

  }

  depends_on = [ 
    google_compute_network.vpc_eu, 
    google_compute_subnetwork.vpc-eu-subnet
    ]
}