provider "template" {
  # See: https://github.com/terraform-providers/terraform-provider-template/blob/v2.0.0/CHANGELOG.md#200-january-14-2019
  # Need to pin the minimum version for templates/fluent.conf
  version = "~> 2.0"
}

data "template_file" "fluentd_tf_rendered_conf" {
  template = file("${path.module}/templates/fluent.conf")

  vars = {
    elasticsearch_route53_url = data.terraform_remote_state.elasticsearch.outputs.route53_url

    fluentd_port = 4224
    es6_support  = false

    s3_bucket     = aws_s3_bucket.logs[0].id
    s3_region     = "ap-southeast-1"
    s3_prefix     = "logs/"
    storage_class = var.logs_s3_storage_class
  }
}

resource "local_file" "fluentd_rendered_conf" {
  content = data.template_file.fluentd_rendered_conf.rendered
  filename = "${path.module}/rendered_fluentd.conf" 
}
