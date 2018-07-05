output "ca_endpoints_der" {
  description = "Endpoints where the CA certificate can be downloaded in DER form"
  value       = "${local.ca_endpoints}"
}

output "ca_endpoints_pem" {
  description = "Endpoints where the CA certificate can be downloaded in PEM form"
  value       = "${formatlist("%s/pem", local.ca_endpoints)}"
}

output "crl_distribution_points" {
  description = "Endpoints to download the CRL"
  value       = "${local.crl_distribution_points}"
}
