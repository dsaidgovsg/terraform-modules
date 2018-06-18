data "template_file" "nomad_server" {
  template = "${file("${path.module}/templates/role.json")}"

  vars {
    type = "server"

    pki_ttl        = "${var.pki_ttl}"
    ou             = "${jsonencode(var.ou)}"
    organization   = "${jsonencode(var.organization)}"
    country        = "${jsonencode(var.country)}"
    locality       = "${jsonencode(var.locality)}"
    province       = "${jsonencode(var.province)}"
    street_address = "${jsonencode(var.street_address)}"
    postal_code    = "${jsonencode(var.postal_code)}"
  }
}

resource "vault_generic_secret" "nomad_server" {
  path = "${vault_mount.pki.path}/roles/server"

  data_json = "${data.template_file.nomad_server.rendered}"
}

data "template_file" "nomad_client" {
  template = "${file("${path.module}/templates/role.json")}"

  vars {
    type = "client"

    pki_ttl        = "${var.pki_ttl}"
    ou             = "${jsonencode(var.ou)}"
    organization   = "${jsonencode(var.organization)}"
    country        = "${jsonencode(var.country)}"
    locality       = "${jsonencode(var.locality)}"
    province       = "${jsonencode(var.province)}"
    street_address = "${jsonencode(var.street_address)}"
    postal_code    = "${jsonencode(var.postal_code)}"
  }
}

resource "vault_generic_secret" "nomad_client" {
  path = "${vault_mount.pki.path}/roles/client"

  data_json = "${data.template_file.nomad_client.rendered}"
}
