# output for the external ip of the eu-asia gateway
output "vpn_gateway_eu_asia_ip" {
  value = google_compute_address.vpn_gateway_eu_asia_ip.address
}

# output for the external ip of the asia-eu gateway
output "vpn_gateway_asia_eu_ip" {
  value = google_compute_address.vpn_gateway_asia_eu_ip.address
}

output "eu_ip_internal" {
  value = "http://${google_compute_instance.vm-eu.network_interface.0.network_ip}"

  depends_on = [ google_compute_instance.vm-eu ]
}

output "na_ip_internal" {
  value = "http://${google_compute_instance.vm-americas-na.network_interface.0.network_ip}"

  depends_on = [ google_compute_instance.vm-americas-na ]
}

output "sa_website_internal" {
  value = "http://${google_compute_instance.vm-americas-sa.network_interface.0.network_ip}"

  depends_on = [ google_compute_instance.vm-americas-sa ]
}

output "asia_website_internal" {
  value = "http://${google_compute_instance.vm-asia.network_interface.0.network_ip}"

  depends_on = [ google_compute_instance.vm-asia ]
}