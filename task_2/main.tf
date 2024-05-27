terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
     random = {
      source = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

# create a random id for the vpc, to avoid conflicts
# source = https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id
# source troubleshooting = https://github.com/hashicorp/terraform-provider-random/issues/106
resource "random_id" "rng" {
   lifecycle {
    ignore_changes = all
    # helps maintain the same id, even if the configuration changes
    # if this is gone, the VPC will have to reapply every time the configuration changes
    # can also comment out the keepers block, because of the timestamp function
  }
  keepers = {
    "first" = "${timestamp()}"
  }     
  byte_length = 4
}

provider "google" {
    credentials = "armageddeon-0d508d6cdae2.json"
    project = "armageddeon"
    region = "us-west1"
}

resource "google_compute_network" "vpc" {
  name = "armageddeon-vpc-${random_id.rng.hex}"
  auto_create_subnetworks = "false"
}

# troubleshooting article with variables: https://kbrzozova.medium.com/basic-firewall-rules-configuration-in-gcp-using-terraform-a87d268fa84f
resource "google_compute_firewall" "vpc_firewall_rules" {
  name    = "${google_compute_network.vpc.name}-terraform-inbound-http"
  network = google_compute_network.vpc.self_link
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  
  allow {
    protocol = "tcp"
    ports    = ["80", "22"]

  }
  # tags are needed to allow the HTTP rule to apply to the instance
  target_tags = ["http-server"]

  
}

resource "google_compute_subnetwork" "vpc-sg" {
  name = "${google_compute_network.vpc.name}-subnet"
  network = google_compute_network.vpc.self_link
  ip_cidr_range = "10.118.1.0/24" 
  region = "us-west1"

  depends_on = [ 
    google_compute_network.vpc, 
    google_compute_firewall.vpc_firewall_rules 
    ]
}

resource "google_compute_instance" "vm" {
  name         = "${google_compute_network.vpc.name}-vm"
  description = "Instance created by Terraform, using the google provider, for VPC ${google_compute_network.vpc.self_link}"
  machine_type = "e2-medium"
  zone         = "us-west1-b"
  tags         = ["http-server"] # tags are needed to allow the HTTP rule to apply to the instance

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.vpc-sg.self_link

  access_config { 
      // Ephemeral/public IP will be geneerated from this block after the instance is created
    }
  }

 
 metadata = {
    "http-server" = "true"
    #ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }
 

  # metadata startup script from local file (ideal for github uploads): file("${path.module}/filename.sh")
  # ensure that script is Linux formatted (LF) and not Windows (CRLF)
  # LF troubleshooting = https://stackoverflow.com/questions/27810758/how-to-replace-crlf-with-lf-in-a-single-file
  metadata_startup_script = file("${path.module}/index.sh")

  # metadata startup script hardcoded (ideal for small scripts)
  #  metadata_startup_script = <<SCRIPT ... SCRIPT

  # metadata startup script for buckets = ["gs://bucket-name/index.sh"]
  # more info on bucket startup scripts = https://github.com/terraform-google-modules/terraform-google-startup-scripts/blob/master/examples/gsutil/main.tf
  # troubleshooting instance startup errors (return code 126 in SSH after running (sudo journalctl -u google-startup-scripts.service)) 
    # https://serverfault.com/questions/923929/gcp-instance-startup-script-error
service_account {
  email = "terraform-service@armageddeon.iam.gserviceaccount.com"
  scopes = ["cloud-platform"]
}
  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.vpc-sg,
    google_compute_firewall.vpc_firewall_rules
  ]
}

output "VPC_name" {
  value = google_compute_network.vpc.id
}

output "VPC_subnet" {
  value = google_compute_subnetwork.vpc-sg.id
}

output "vm_website_internal" {
  value = "http://${google_compute_instance.vm.network_interface.0.network_ip}"

  depends_on = [ google_compute_instance.vm ]
}

output "vm_website_external" {
  value = "http://${google_compute_instance.vm.network_interface.0.access_config[0].nat_ip}"

  depends_on = [ google_compute_instance.vm ]
}