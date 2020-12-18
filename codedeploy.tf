resource "aws_codedeploy_app" "scribble_deploy" {
  compute_platform = "Server"
  name             = "scribble-codedeploy-terraform"
}

resource "aws_sns_topic" "scribble_sns_terraform" {
  name = "scribble-sns-topic"
}

resource "aws_codedeploy_deployment_group" "scribble_codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.scribble_deploy.name
  deployment_group_name = "scribble-deploy-group-terraform"
  service_role_arn      = aws_iam_role.scribble_codedeploy_role.arn

  autoscaling_groups = [module.example_asg.this_autoscaling_group_name]
  load_balancer_info {
    elb_info {
      name = module.elb.this_elb_name
    }
  }

  trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "scribble-codedeploy-trigger-terraform"
    trigger_target_arn = aws_sns_topic.scribble_sns_terraform.arn
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["scribble-codedeploy-alarm-terraform"]
    enabled = true
  }
}