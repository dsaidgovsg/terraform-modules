output "jobspec" {
  description = "Rendered jobspec"
  value = "${data.template_file.fluentd_jobspec.rendered}"
}
