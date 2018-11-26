locals {
  aws_cloudwatch_datasource = "${var.cloudwatch_datasource_aws_path != ""}"
}

data "aws_availability_zones" "available" {}

data "template_file" "grafana_config" {
  template = "${file("${path.module}/templates/grafana.ini")}"

  vars {
    instance_name     = "${var.grafana_job_name}"
    grafana_bind_addr = "${var.grafana_bind_addr}"
    grafana_port      = "${var.grafana_port}"
    grafana_domain    = "${coalesce(var.grafana_domain, element(var.grafana_fqdns, 0))}"
    router_logging    = "${var.grafana_router_logging}"

    database_type     = "${var.grafana_database_type}"
    database_host     = "${var.grafana_database_host}"
    database_port     = "${var.grafana_database_port}"
    database_name     = "${var.grafana_database_name}"
    database_ssl_mode = "${var.grafana_database_ssl_mode}"

    vault_database_path          = "${var.vault_database_path}"
    vault_database_username_path = "${var.vault_database_username_path}"
    vault_database_password_path = "${var.vault_database_password_path}"

    vault_admin_path          = "${var.vault_admin_path}"
    vault_admin_username_path = "${var.vault_admin_username_path}"
    vault_admin_password_path = "${var.vault_admin_password_path}"

    session_provider = "${var.session_provider}"
    session_config   = "${var.session_config}"

    grafana_additional_config = "${var.grafana_additional_config}"
  }
}

data "template_file" "grafana_jobspec" {
  template = "${file("${path.module}/templates/grafana.nomad")}"

  vars {
    region     = "${var.aws_region}"
    az         = "${jsonencode(coalescelist(var.nomad_azs, data.aws_availability_zones.available.names))}"
    policies   = "${jsonencode(var.grafana_vault_policies)}"
    node_class = "${var.nomad_clients_node_class}"
    count      = "${var.grafana_count}"
    job_name   = "${var.grafana_job_name}"

    grafana_fqdns       = "${join(",", var.grafana_fqdns)}"
    grafana_port        = "${var.grafana_port}"
    grafana_image       = "${var.grafana_image}"
    grafana_tag         = "${var.grafana_tag}"
    grafana_force_pull  = "${var.grafana_force_pull}"
    grafana_entrypoints = "${join(",", var.grafana_entrypoints)}"

    grafana_conf_template            = "${data.template_file.grafana_config.rendered}"
    grafana_dashboards               = "${file("${path.module}/templates/dashboards.yml")}"
    cloudwatch_datasource            = "${data.template_file.grafana_datasource_cloudwatch.rendered}"
    grafana_dashboard_aws_billing    = "${data.template_file.grafana_dashboard_aws_billing.rendered}"
    grafana_dashboard_aws_cloudwatch = "${data.template_file.grafana_dashboard_aws_cloudwatch.rendered}"

    additional_driver_config = "${var.additional_driver_config}"
    additional_task_config   = "${var.additional_task_config}"
  }
}

data "template_file" "grafana_datasource_cloudwatch" {
  template = "${local.aws_cloudwatch_datasource ? file("${path.module}/templates/datasources/cloudwatch.yml"): ""}"

  vars {
    name       = "${var.cloudwatch_datasource_name}"
    aws_path   = "${var.cloudwatch_datasource_aws_path}"
    aws_region = "${var.aws_region}"
  }
}

data "template_file" "grafana_dashboard_aws_billing" {
  template = "${local.aws_cloudwatch_datasource && var.aws_billing_dashboard ? file("${path.module}/templates/dashboards/aws-billing.json"): ""}"

  vars {
    cloudwatch_data_source_name = "${var.cloudwatch_datasource_name}"
  }
}

data "template_file" "grafana_dashboard_aws_cloudwatch" {
  template = "${local.aws_cloudwatch_datasource && var.aws_cloudwatch_dashboard ? file("${path.module}/templates/dashboards/aws-cloudwatch.json"): ""}"

  vars {
    cloudwatch_data_source_name = "${var.cloudwatch_datasource_name}"
  }
}

resource "nomad_job" "grafana" {
  jobspec = "${data.template_file.grafana_jobspec.rendered}"
}
