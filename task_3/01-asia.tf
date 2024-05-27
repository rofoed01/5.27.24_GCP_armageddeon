resource "google_compute_network" "vpc_asia" {
  name = "asia-${random_id.rng.hex}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "vpc-asia-subnet" {
  name = "asiaeast1-${google_compute_network.vpc_asia.name}"
  network = google_compute_network.vpc_asia.self_link
  ip_cidr_range = "192.168.18.0/24" 
  region = "asia-east1"
  private_ip_google_access = "true"

  depends_on = [ 
    google_compute_network.vpc_asia, 
    google_compute_firewall.vpc_asia_firewall 
    ]
}

resource "google_compute_firewall" "vpc_asia_firewall" {
  name    = "${google_compute_network.vpc_asia.name}-rules"
  network = google_compute_network.vpc_asia.self_link
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  allow {
    protocol = "icmp"
  }
  
  target_tags = ["asia", "rdp-server"]
  
}

resource "google_compute_instance" "vm-asia" {
  name         = "vm-${google_compute_network.vpc_asia.name}"
  description = "Instance created by Terraform, using the google provider, for VPC ${google_compute_network.vpc_asia.self_link}"
  machine_type = "e2-standard-2"
  zone         = "asia-east1-b"
  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  
  boot_disk {
    auto_delete = "true"
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240516"
      size  = 80
      type  = "pd-balanced"
    }
    mode = "READ_WRITE"
  }

  network_interface {
    network = google_compute_network.vpc_asia.self_link
    subnetwork = google_compute_subnetwork.vpc-asia-subnet.self_link

  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  depends_on = [ 
    google_compute_network.vpc_asia, 
    google_compute_subnetwork.vpc-asia-subnet
    ]
}