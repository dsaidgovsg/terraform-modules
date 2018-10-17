resource "aws_cloudwatch_metric_alarm" "cluster_status_red" {
  count = "${var.cluster_status_red_enable ? 1 : 0 }"

  alarm_name          = "${var.cluster_status_red_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.cluster_status_red_evaluation_periods}"
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = "${var.cluster_status_red_period}"
  statistic           = "Maximum"
  threshold           = "${var.cluster_status_red_threshold}"
  alarm_description   = "At least one primary shard and its replicas are not allocated to a node"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_yellow" {
  count = "${var.cluster_status_yellow_enable ? 1 : 0}"

  alarm_name          = "${var.cluster_status_yellow_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.cluster_status_yellow_evaluation_periods}"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "${var.cluster_status_yellow_period}"
  statistic           = "Maximum"
  threshold           = "${var.cluster_status_yellow_threshold}"
  alarm_description   = "At least one replica shard is not allocated to a node"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "low_storage_space" {
  count = "${var.low_storage_space_enable ? 1 : 0}"

  alarm_name          = "${var.low_storage_space_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "${var.es_ebs_volume_size * 256}"
  alarm_description   = "Less than 25% of ${var.es_ebs_volume_size} storage space available"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "cluster_index_writes_blocked" {
  count = "${var.cluster_index_writes_blocked_enable ? 1 : 0}"

  alarm_name          = "${var.cluster_index_writes_blocked_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.cluster_index_writes_blocked_evaluation_periods}"
  metric_name         = "ClusterIndexWritesBlocked"
  namespace           = "AWS/ES"
  period              = "${var.cluster_index_writes_blocked_period}"
  statistic           = "SampleCount"
  threshold           = "${var.cluster_index_writes_blocked_threshold}"
  alarm_description   = "Cluster is blocking write request due to lack of available storage space or memory"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "node_unreachable" {
  count = "${var.node_unreachable_enable ? 1 : 0}"

  alarm_name          = "${var.node_unreachable_alarm_name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "${var.node_unreachable_evaluation_periods}"
  metric_name         = "Nodes"
  namespace           = "AWS/ES"
  period              = "${var.node_unreachable_period}"
  statistic           = "Minimum"
  threshold           = "${var.es_instance_count}"
  alarm_description   = "Node in your cluster has been unreachable for one day."
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "snapshot_failed" {
  count = "${var.snapshot_failed_enable ? 1 : 0}"

  alarm_name          = "${var.snapshot_failed_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.snapshot_failed_evaluation_periods}"
  metric_name         = "AutomatedSnapshotFailure"
  namespace           = "AWS/ES"
  period              = "${var.snapshot_failed_period}"
  statistic           = "Maximum"
  threshold           = "${var.snapshot_failed_threshold}"
  alarm_description   = "An automated snapshot failed"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization_data_node" {
  count = "${var.high_cpu_utilization_data_node_enable ? 1 : 0}"

  alarm_name          = "${var.high_cpu_utilization_data_node_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_cpu_utilization_data_node_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = "${var.high_cpu_utilization_data_node_period}"
  statistic           = "Average"
  threshold           = "${var.high_cpu_utilization_master_node_threshold}"
  alarm_description   = "High cpu utilization for 15mins"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "high_jvm_memory_utilization_data_node" {
  count = "${var.high_jvm_memory_utilization_data_node_enable ? 1 : 0}"

  alarm_name          = "${var.high_jvm_memory_utilization_data_node_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_jvm_memory_utilization_data_node_evaluation_periods}"
  metric_name         = "JVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = "${var.high_jvm_memory_utilization_data_node_period}"
  statistic           = "Maximum"
  threshold           = "${var.high_jvm_memory_utilization_data_node_threshold}"
  alarm_description   = "High JVM memory utilization for 15mins"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization_master_node" {
  count = "${var.high_cpu_utilization_master_node_enable ? 1 : 0}"

  alarm_name          = "${var.high_cpu_utilization_master_node_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_cpu_utilization_master_node_evaluation_periods}"
  metric_name         = "MasterCPUUtilization"
  namespace           = "AWS/ES"
  period              = "${var.high_cpu_utilization_master_node_period}"
  statistic           = "Average"
  threshold           = "${var.high_cpu_utilization_master_node_threshold}"
  alarm_description   = "High cpu utilization for master node"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "high_jvm_memory_utilization_master_node" {
  count = "${var.high_jvm_memory_utilization_master_node_enable ? 1 : 0}"

  alarm_name          = "${var.high_jvm_memory_utilization_master_node_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.high_jvm_memory_utilization_master_node_evaluation_periods}"
  metric_name         = "MasterJVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = "${var.high_jvm_memory_utilization_master_node_period}"
  statistic           = "Maximum"
  threshold           = "${var.high_jvm_memory_utilization_master_node_threshold}"
  alarm_description   = "High JVM memory utilization for 15mins"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "kms_key_error" {
  count = "${var.kms_key_error_enable ? 1 : 0}"

  alarm_name          = "${var.kms_key_error_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.kms_key_error_evaluation_periods}"
  metric_name         = "kmsKeyError"
  namespace           = "AWS/ES"
  period              = "${var.kms_key_error_period}"
  statistic           = "SampleCount"
  threshold           = "${var.kms_key_error_threshold}"
  alarm_description   = "The kms encryption key that is used to encrypt data at rest in your domain is disabled"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}

resource "aws_cloudwatch_metric_alarm" "kms_key_inaccessible" {
  count = "${var.kms_key_inaccessible_enable ? 1 : 0}"

  alarm_name          = "${var.kms_key_inaccessible_alarm_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.kms_key_inaccessible_evaluation_periods}"
  metric_name         = "kmsKeyInaccessible"
  namespace           = "AWS/ES"
  period              = "${var.kms_key_inaccessible_period}"
  statistic           = "SampleCount"
  threshold           = "${var.kms_key_inaccessible_threshold}"
  alarm_description   = "The kms encryption key has been deleted or has revoked its grants to Amazon ES"
  alarm_actions       = ["${var.alarm_actions}"]
  ok_actions          = ["${var.ok_actions}"]
}
