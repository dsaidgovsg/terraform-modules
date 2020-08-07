## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alarm\_actions | A list of ARNs (i.e. SNS Topic ARN) to notify for alarm action | `list(string)` | `[]` | no |
| base\_domain | Base domain for Elasticsearch cluster | `string` | n/a | yes |
| cluster\_index\_writes\_blocked\_alarm\_name | Name of the alarm | `string` | `"cluster_index_writes_blocked_alarm"` | no |
| cluster\_index\_writes\_blocked\_enable | Whether to enable alarm | `bool` | `false` | no |
| cluster\_index\_writes\_blocked\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| cluster\_index\_writes\_blocked\_period | Duration in seconds to evaluate for the alarm. | `string` | `"300"` | no |
| cluster\_index\_writes\_blocked\_threshold | Threshold for the number of write request blocked | `string` | `"1"` | no |
| cluster\_status\_red\_alarm\_name | Name of the alarm. | `string` | `"cluster_status_red_alarm"` | no |
| cluster\_status\_red\_enable | Whether to enable alarm | `bool` | `false` | no |
| cluster\_status\_red\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| cluster\_status\_red\_period | Duration in seconds to evaluate for the alarm. | `string` | `"60"` | no |
| cluster\_status\_red\_threshold | Threshold for the number of primary shard not allocated to a node | `string` | `"1"` | no |
| cluster\_status\_yellow\_alarm\_name | Name of the alarm | `string` | `"cluster_status_yellow_alarm"` | no |
| cluster\_status\_yellow\_enable | Whether to enable alarm | `bool` | `false` | no |
| cluster\_status\_yellow\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| cluster\_status\_yellow\_period | Duration in seconds to evaluate for the alarm. | `string` | `"60"` | no |
| cluster\_status\_yellow\_threshold | Threshold for the number of replicas shard not allocated to a node | `string` | `"1"` | no |
| create\_service\_linked\_role | Create Elasticsearch service linked role. See README | `bool` | `false` | no |
| enable\_slow\_index\_log | Enable slow log indexing | `bool` | `false` | no |
| es\_access\_cidr\_block | Elasticsearch access CIDR block to allow access | `list(string)` | n/a | yes |
| es\_additional\_tags | Additional tags to apply on Elasticsearch | `map(string)` | `{}` | no |
| es\_dedicated\_master\_enabled | Enable dedicated master nodes for Elasticsearch | `bool` | n/a | yes |
| es\_default\_access | Rest API / Web UI access | `map(any)` | <pre>{<br>  "port": 443,<br>  "protocol": "tcp",<br>  "type": "ingress"<br>}<br></pre> | no |
| es\_domain\_name | Elasticsearch domain name | `string` | n/a | yes |
| es\_ebs\_volume\_size | Volume capacity for attached EBS in GB for each node | `number` | n/a | yes |
| es\_ebs\_volume\_type | Storage type of EBS volumes, if used (default gp2) | `string` | n/a | yes |
| es\_encrypt\_at\_rest | Encrypts the data stored by Elasticsearch at rest | `bool` | `false` | no |
| es\_http\_iam\_roles | List of IAM role ARNs from which to permit Elasticsearch HTTP traffic (default ['\*']).<br>Note that a client must match both the IP address and the IAM role patterns in order to be permitted access. | `list(string)` | <pre>[<br>  "*"<br>]<br></pre> | no |
| es\_instance\_count | Number of nodes to be deployed in Elasticsearch | `number` | n/a | yes |
| es\_instance\_type | Elasticsearch instance type for non-master node | `string` | n/a | yes |
| es\_kms\_key\_id | kms Key ID for encryption at rest. Defaults to AWS service key. | `string` | `"aws/es"` | no |
| es\_master\_count | Number of dedicated master nodes in Elasticsearch | `number` | n/a | yes |
| es\_master\_type | Elasticsearch instance type for dedicated master node | `string` | n/a | yes |
| es\_snapshot\_start\_hour | Hour at which automated snapshots are taken, in UTC (default 0) | `number` | `19` | no |
| es\_version | Elasticsearch version to deploy | `string` | `"5.5"` | no |
| es\_vpc\_subnet\_ids | Subnet IDs for Elasticsearch cluster | `list(string)` | n/a | yes |
| es\_zone\_awareness | Enable zone awareness for Elasticsearch cluster | `string` | `"true"` | no |
| high\_cpu\_utilization\_data\_node\_alarm\_name | Name of the alarm | `string` | `"high_cpu_utilization_data_node_alarm"` | no |
| high\_cpu\_utilization\_data\_node\_enable | Whether to enable alarm | `bool` | `false` | no |
| high\_cpu\_utilization\_data\_node\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"3"` | no |
| high\_cpu\_utilization\_data\_node\_period | Duration in seconds to evaluate for the alarm. | `string` | `"900"` | no |
| high\_cpu\_utilization\_data\_node\_threshold | Threshold % of cpu utilization for data node | `string` | `"80"` | no |
| high\_cpu\_utilization\_master\_node\_alarm\_name | Name of the alarm | `string` | `"high_cpu_utilization_master_node_alarm"` | no |
| high\_cpu\_utilization\_master\_node\_enable | Whether to enable alarm | `bool` | `false` | no |
| high\_cpu\_utilization\_master\_node\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"3"` | no |
| high\_cpu\_utilization\_master\_node\_period | Duration in seconds to evaluate for the alarm. | `string` | `"900"` | no |
| high\_cpu\_utilization\_master\_node\_threshold | Threshold % of cpu utilization for master node | `string` | `"50"` | no |
| high\_jvm\_memory\_utilization\_data\_node\_alarm\_name | Name of the alarm | `string` | `"high_jvm_memory_utilization_data_node_alarm"` | no |
| high\_jvm\_memory\_utilization\_data\_node\_enable | Whether to enable alarm | `bool` | `false` | no |
| high\_jvm\_memory\_utilization\_data\_node\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| high\_jvm\_memory\_utilization\_data\_node\_period | Duration in seconds to evaluate for the alarm. | `string` | `"900"` | no |
| high\_jvm\_memory\_utilization\_data\_node\_threshold | Threshold % of jvm memory utilization for data node | `string` | `"80"` | no |
| high\_jvm\_memory\_utilization\_master\_node\_alarm\_name | Name of the alarm | `string` | `"high_jvm_memory_utilization_master_node_alarm"` | no |
| high\_jvm\_memory\_utilization\_master\_node\_enable | Whether to enable alarm | `bool` | `false` | no |
| high\_jvm\_memory\_utilization\_master\_node\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| high\_jvm\_memory\_utilization\_master\_node\_period | Duration in seconds to evaluate for the alarm. | `string` | `"900"` | no |
| high\_jvm\_memory\_utilization\_master\_node\_threshold | Threshold % of jvm memory utilization for master node | `string` | `"80"` | no |
| kms\_key\_error\_alarm\_name | Name of the alarm | `string` | `"kms_key_error_alarm"` | no |
| kms\_key\_error\_enable | Whether to enable alarm | `bool` | `false` | no |
| kms\_key\_error\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| kms\_key\_error\_period | Duration in seconds to evaluate for the alarm. | `string` | `"60"` | no |
| kms\_key\_error\_threshold | Threshold for the number of kms key error | `string` | `"1"` | no |
| kms\_key\_inaccessible\_alarm\_name | Name of the alarm | `string` | `"kms_key_inaccessible_alarm"` | no |
| kms\_key\_inaccessible\_enable | Whether to enable alarm | `bool` | `false` | no |
| kms\_key\_inaccessible\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| kms\_key\_inaccessible\_period | Duration in seconds to evaluate for the alarm. | `string` | `"60"` | no |
| kms\_key\_inaccessible\_threshold | Threshold for the number of kms key inaccessible error | `string` | `"1"` | no |
| low\_storage\_space\_enable | Whether to enable alarm | `bool` | `false` | no |
| low\_storage\_space\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| low\_storage\_space\_name | Name of the alarm | `string` | `"low_storage_space_alarm"` | no |
| low\_storage\_space\_yellow\_period | Duration in seconds to evaluate for the alarm. | `string` | `"60"` | no |
| node\_unreachable\_alarm\_name | Name of the alarm | `string` | `"node_unreachable_enable_alarm"` | no |
| node\_unreachable\_enable | Whether to enable alarm | `bool` | `false` | no |
| node\_unreachable\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| node\_unreachable\_period | Duration in seconds to evaluate for the alarm. | `string` | `"86400"` | no |
| ok\_actions | A list of ARNs (i.e. SNS Topic ARN) to notify for ok action | `list(string)` | `[]` | no |
| security\_group\_additional\_tags | Additional tags to apply on the security group | `map(string)` | `{}` | no |
| security\_group\_name | Name of security group, leaving this empty generates a group name | `string` | n/a | yes |
| security\_group\_vpc\_id | VPC ID to apply on the security group | `string` | n/a | yes |
| slow\_index\_additional\_tags | Additional tags to apply on Cloudwatch log group | `map(string)` | `{}` | no |
| slow\_index\_log\_name | Name of the Cloudwatch log group for slow index | `string` | `"es-slow-index"` | no |
| slow\_index\_log\_retention | Number of days to retain logs for. | `string` | `"120"` | no |
| snapshot\_failed\_alarm\_name | Name of the alarm | `string` | `"snapshot_failed_alarm"` | no |
| snapshot\_failed\_enable | Whether to enable alarm | `bool` | `false` | no |
| snapshot\_failed\_evaluation\_periods | Number of periods to evaluate for the alarm. | `string` | `"1"` | no |
| snapshot\_failed\_period | Duration in seconds to evaluate for the alarm. | `string` | `"60"` | no |
| snapshot\_failed\_threshold | Threshold for the number of snapshot failed | `string` | `"1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the created Elasticsearch domain |
| domain\_id | Unique identifier for the domain |
| domain\_name | Elasticsearch domain name |
| elasticsearch\_url | Elasticsearch URL |
| endpoint | Domain-specific endpoint used to submit index, search, and data upload requests |
| kibana\_url | Kibana URL |
| port | Elasticsearch service port |
| security\_group\_id | ID of the Security Group attached to Elasticsearch |

