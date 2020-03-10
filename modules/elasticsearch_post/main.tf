resource "aws_security_group_rule" "es_post_access_rule" {
  type              = var.es_default_access["type"]
  from_port         = var.es_default_access["port"]
  to_port           = var.es_default_access["port"]
  protocol          = var.es_default_access["protocol"]
  cidr_blocks       = var.es_post_access_cidr_block
  security_group_id = var.es_security_group_id
}
