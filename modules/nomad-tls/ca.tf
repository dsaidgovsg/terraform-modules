data "template_file" "ca" {
  template = "${file("${path.module}/templates/ca.json")}"

  vars {
    ca                   = "${jsonencode(var.ca_cn)}"
    ca_san               = "${jsonencode(var.ca_san)}"
    ca_ip_san            = "${jsonencode(var.ca_ip_san)}"
    ttl                  = "${var.pki_max_ttl}"
    exclude_cn_from_sans = "${jsonencode(var.ca_exclude_cn_from_sans)}"

    ou             = "${jsonencode(var.ou)}"
    organization   = "${jsonencode(var.organization)}"
    country        = "${jsonencode(var.country)}"
    locality       = "${jsonencode(var.locality)}"
    province       = "${jsonencode(var.province)}"
    street_address = "${jsonencode(var.street_address)}"
    postal_code    = "${jsonencode(var.postal_code)}"
  }
}

resource "vault_generic_secret" "pki_ca" {
  path         = "${vault_mount.pki.path}/root/generate/internal"
  disable_read = true
  data_json    = "${data.template_file.ca.rendered}"

  lifecycle {
    # This is a hack. Reconfiguring this will overwrite the CA
    ignore_changes = ["*"]
  }
}
