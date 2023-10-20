# AWS EC2 Container Registry Repository

Provides an EC2 Container Registry Repository.

## Example usage

```hcl
module "ecr" {
  source = "/path/to/vendor/terraform-modules/modules/ecr"

  name = "${var.ecr_name}"
  tags = "${var.tags}"

  add_route53_record = true
  route53_zone_id    = "${var.route53_zone_id}"
  route53_domain     = "mydocker"

  lb_cname              = "${var.core_internal_lb_dns_name}"
  lb_zone_id            = "${var.core_internal_lb_zone_id}"
  redirect_listener_arn = "${var.core_internal_lb_https_listener_arn}"
  redirect_rule_priority = 100
}
```

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
