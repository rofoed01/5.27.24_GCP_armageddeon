# FLIP EVERYTHING

# start of vpn gateway from eu to asia
resource "google_compute_vpn_gateway" "vpn_gateway_asia_eu" {
  name = "asia-eu-gateway-${random_id.rng.hex}"
  network = google_compute_network.vpc_asia.name
  region = "asia-east1"
  depends_on = [ google_compute_subnetwork.vpc-asia-subnet, google_compute_firewall.vpc_asia_firewall ]
}

# creating external ip for the asia-eu gateway
resource "google_compute_address" "vpn_gateway_asia_eu_ip" {
  name = "ip-${google_compute_vpn_gateway.vpn_gateway_asia_eu.name}"
  region = "asia-east1"
  depends_on = [ google_compute_vpn_gateway.vpn_gateway_asia_eu ]
}

# creating forwarding rule 1 for the asia-eu gateway; ESP protocol is critical
resource "google_compute_forwarding_rule" "vpn_gateway_asia_eu_forwarding_rule1" {
  name = "asia-eu-gateway-forwarding-rule1-${random_id.rng.hex}"
  region = "asia-east1"
  ip_protocol = "ESP"
  ip_address = google_compute_address.vpn_gateway_asia_eu_ip.address
  target = google_compute_vpn_gateway.vpn_gateway_asia_eu.self_link
  depends_on = [ google_compute_address.vpn_gateway_asia_eu_ip, google_compute_vpn_gateway.vpn_gateway_asia_eu ]
}

# creating forwarding rule 2 for the asia-eu gateway; UDP port 500
resource "google_compute_forwarding_rule" "vpn_gateway_asia_eu_forwarding_rule2" {
  name = "asia-eu-gateway-forwarding-rule2-${random_id.rng.hex}"
  region = "asia-east1"
  ip_protocol = "UDP"
  port_range = "500"
  ip_address = google_compute_address.vpn_gateway_asia_eu_ip.address
  target = google_compute_vpn_gateway.vpn_gateway_asia_eu.self_link
  depends_on = [ google_compute_address.vpn_gateway_asia_eu_ip, google_compute_vpn_gateway.vpn_gateway_asia_eu ]
  
}

# creating forwarding rule 3 for the asia-eu gateway; UDP port 4500
resource "google_compute_forwarding_rule" "vpn_gateway_asia_eu_forwarding_rule3" {
  name = "asia-eu-gateway-forwarding-rule3-${random_id.rng.hex}"
  region = "asia-east1"
  ip_protocol = "UDP"
  port_range = "4500"
  ip_address = google_compute_address.vpn_gateway_asia_eu_ip.address
  target = google_compute_vpn_gateway.vpn_gateway_asia_eu.self_link
  depends_on = [ google_compute_address.vpn_gateway_asia_eu_ip, google_compute_vpn_gateway.vpn_gateway_asia_eu ]
}

# creating tunnel 1 for the asia-eu gateway
resource "google_compute_vpn_tunnel" "vpn_tunnel_asia_eu1" {
  name = "asia-eu-tunnel1-${random_id.rng.hex}"
  target_vpn_gateway = google_compute_vpn_gateway.vpn_gateway_asia_eu.id
  peer_ip = google_compute_address.vpn_gateway_eu_asia_ip.address
  shared_secret = "mysecret"
  ike_version = 2
  local_traffic_selector = [google_compute_subnetwork.vpc-asia-subnet.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.vpc-eu-subnet.ip_cidr_range]
  
  depends_on = [ 
    google_compute_vpn_gateway.vpn_gateway_asia_eu,
    google_compute_forwarding_rule.vpn_gateway_asia_eu_forwarding_rule1,
    google_compute_forwarding_rule.vpn_gateway_asia_eu_forwarding_rule2,
    google_compute_forwarding_rule.vpn_gateway_asia_eu_forwarding_rule3,
    google_compute_address.vpn_gateway_eu_asia_ip
    ]
}

# creating route 1 for the asia-eu gateway
resource "google_compute_route" "vpn_route_asia_eu1" {
  name = "asia-eu-route1-${random_id.rng.hex}"
  network = google_compute_network.vpc_asia.id
  dest_range = google_compute_subnetwork.vpc-eu-subnet.ip_cidr_range
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.vpn_tunnel_asia_eu1.id
  depends_on = [ google_compute_vpn_tunnel.vpn_tunnel_asia_eu1 ]
}

# internal traffic firewall
resource "google_compute_firewall" "gateway_asia_eu_internal_traffic_firewall" {
  name    = "internal-route-${google_compute_vpn_gateway.vpn_gateway_asia_eu.name}"
  network = google_compute_network.vpc_asia.name
  direction = "INGRESS"
  source_ranges = [google_compute_subnetwork.vpc-eu-subnet.ip_cidr_range]

    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "tcp"
        ports    = ["22", "3389"]
    }

}