# Nomad Cluster

This is a copy-pasted version of [HashiCorp's Nomad Cluster](github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=v0.5.0) but with the addition of a spot price variable which was excluded in the original module.

Also, the variables `subnet_ids` and `availability_zones` have been set to `null` instead of an empty list `[]` to prevent terraform from not applying as per <https://github.com/hashicorp/terraform-aws-nomad/pull/74>

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
