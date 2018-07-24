# Simple Job in Nomad to redirect users to the very unfriendly Kibana URL

data "aws_route53_zone" "internal" {
  name = "${var.route53_zone_internal}"
}

# Define the DNS record to point to the external LB
resource "aws_route53_record" "redirect" {
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name    = "${local.redirect_domain}"
  type    = "A"

  alias {
    name                   = "${var.redirect_alias_name}"
    zone_id                = "${data.aws_route53_zone.internal.zone_id}"
    evaluate_target_health = false
  }
}

data "template_file" "redirect_jobspec" {
  template = "${file("${path.module}/templates/redirect.nomad")}"

  vars {
    region = "${var.redirect_job_region}"
    az     = "${jsonencode(var.redirect_job_vpc_azs)}"

    elasticsearch_service  = "${var.es_consul_service}"
    redirect_domain        = "${local.redirect_domain}"
    redirect_job_name      = "${var.redirect_job_name}"
    redirect_nginx_version = "${var.redirect_nginx_version}"
  }
}

resource "nomad_job" "redirect" {
  depends_on = ["consul_service.es"]
  jobspec    = "${data.template_file.redirect_jobspec.rendered}"
}
