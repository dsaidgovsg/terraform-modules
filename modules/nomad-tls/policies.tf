data "template_file" "server_policy" {
  template = "${file("${path.module}/templates/server_policy.hcl")}"

  vars {
    pki_path    = "${vault_mount.pki.path}"
    gossip_path = "${var.gossip_path}"
    role        = "server"
  }
}

resource "vault_policy" "server" {
  name   = "${var.nomad_server_policy}"
  policy = "${data.template_file.server_policy.rendered}"
}

data "template_file" "client_policy" {
  template = "${file("${path.module}/templates/client_policy.hcl")}"

  vars {
    pki_path = "${vault_mount.pki.path}"
    role     = "client"
  }
}

resource "vault_policy" "client" {
  name   = "${var.nomad_client_policy}"
  policy = "${data.template_file.client_policy.rendered}"
}
