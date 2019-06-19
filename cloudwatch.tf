resource "aws_cloudwatch_log_group" "munki_makecatalogs" {
  name              = "/aws/lambda/munki_makecatalogs"
  retention_in_days = "30"

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_cloudwatch_log_metric_filter" "warnings" {
  name           = "WARNING"
  pattern        = "WARNING"
  log_group_name = aws_cloudwatch_log_group.munki_makecatalogs.name

  metric_transformation {
    name      = "WARNING"
    namespace = "munki_makecatalogs"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "errors" {
  name           = "ERROR"
  pattern        = "error"
  log_group_name = aws_cloudwatch_log_group.munki_makecatalogs.name

  metric_transformation {
    name      = "ERROR"
    namespace = "munki_makecatalogs"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "Makecatalogs-Warning" {
  count                     = var.alarm_arn != "" ? 1 : 0
  alarm_name                = "Makecatalogs Warning"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "WARNING"
  namespace                 = "munki_makecatalogs"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Munki makecatalogs has a warning!"
  treat_missing_data        = "notBreaching"
  alarm_actions             = [var.alarm_arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "Makecatalogs-Error" {
  count                     = var.alarm_arn != "" ? 1 : 0
  alarm_name                = "Makecatalogs Error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "ERROR"
  namespace                 = "munki_makecatalogs"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Munki makecatalogs has a error!"
  treat_missing_data        = "notBreaching"
  alarm_actions             = [var.alarm_arn]
  insufficient_data_actions = []
}

