# Vault Security Group Rules Module

This folder contains a [Terraform](https://www.terraform.io/) module that defines the security group rules used by a 
[Vault](https://www.vaultproject.io/) cluster to control the traffic that is allowed to go in and out of the cluster. 

Normally, you'd get these rules by default if you're using the [vault-cluster module](https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/vault-cluster), but if 
you're running Vault on top of a different cluster, then you can use this module to add the necessary security group 
rules to that cluster. For example, imagine you were using the [consul-cluster 
module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/consul-cluster) to run a cluster of 
servers that have both Vault and Consul on each node:

```hcl
module "cluster" {
  source = "github.com/hashicorp/terraform-aws-consul.git/modules/consul-cluster?ref=v0.0.1"
  
  # This AMI has both Vault and Consul installed
  ami_id = "ami-1234abcd"
}
```

The `consul-cluster` module will provide the security group rules for Consul, but not for Vault. To ensure those 
servers have the necessary ports open for using Vault, you can use this module as follows:


```hcl
module "security_group_rules" {
  source = github.com/hashicorp/terraform-aws-consul.git/modules/vault-security-group-rules?ref=v0.0.1"

  security_group_id = "${module.cluster.security_group_id}"
  
  # ... (other params omitted) ...
}
```

Note the following parameters:

* `source`: Use this parameter to specify the URL of this module. The double slash (`//`) is intentional 
  and required. Terraform uses it to specify subfolders within a Git repo (see [module 
  sources](https://www.terraform.io/docs/modules/sources.html)). The `ref` parameter specifies a specific Git tag in 
  this repo. That way, instead of using the latest version of this module from the `master` branch, which 
  will change every time you run Terraform, you're using a fixed version of the repo.

* `security_group_id`: Use this parameter to specify the ID of the security group to which the rules in this module
  should be added.
  
You can find the other parameters in [variables.tf](variables.tf).

Check out the [vault-cluster module](https://github.com/hashicorp/terraform-aws-vault/tree/master/modules/vault-cluster) for example usage.
