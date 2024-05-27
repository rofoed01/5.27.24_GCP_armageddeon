resource "google_compute_network" "vpc_americas" {
  name = "americas-${random_id.rng.hex}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "vpc-americas-NA" {
  name = "na-${google_compute_network.vpc_americas.name}"
  network = google_compute_network.vpc_americas.self_link
  ip_cidr_range = "172.20.18.0/24" 
  region = "us-west1"
  private_ip_google_access = "true"

  depends_on = [ 
    google_compute_network.vpc_americas, 
   #  google_compute_firewall.vpc_firewall_rules 
    ]
}

resource "google_compute_subnetwork" "vpc-americas-SA" {
  name = "sa-${google_compute_network.vpc_americas.name}"
  network = google_compute_network.vpc_americas.self_link
  ip_cidr_range = "172.30.18.0/24" 
  region = "southamerica-west1"
  private_ip_google_access = "true"

  depends_on = [ 
    google_compute_network.vpc_americas, 
    google_compute_firewall.vpc_americas_firewall
    ]
}

resource "google_compute_firewall" "vpc_americas_firewall" {
  name    = "${google_compute_network.vpc_americas.name}-rules"
  network = google_compute_network.vpc_americas.self_link
  direction = "INGRESS"
  source_ranges = ["10.18.1.0/24", "192.168.18.0/24"]
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "icmp"
  }
  
  target_tags = ["americas", "http-server"]
  
}

resource "google_compute_instance" "vm-americas-na" {
  name         = "vm-${google_compute_network.vpc_americas.name}"
  description = "Instance created by Terraform, using the google provider, for VPC ${google_compute_network.vpc_americas.self_link}"
  machine_type = "e2-medium"
  zone         = "us-west1-b"
  tags = ["americas", "http-server"]
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_americas.self_link
    subnetwork = google_compute_subnetwork.vpc-americas-NA.self_link

  }

  depends_on = [ 
    google_compute_network.vpc_americas, 
    google_compute_subnetwork.vpc-americas-NA
    ]
}

resource "google_compute_instance" "vm-americas-sa" {
  name         = "vm-${google_compute_network.vpc_americas.name}"
  description = "Instance created by Terraform, using the google provider, for VPC ${google_compute_network.vpc_americas.self_link}"
  machine_type = "e2-medium"
  zone         = "southamerica-west1-b"
  tags = ["americas", "http-server"]
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_americas.self_link
    subnetwork = google_compute_subnetwork.vpc-americas-SA.self_link

  }

  depends_on = [ 
    google_compute_network.vpc_americas, 
    google_compute_subnetwork.vpc-americas-SA
    ]
}