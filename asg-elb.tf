##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

######
# Launch configuration and autoscaling group
######
module "example_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = "scribble-asg-with-elb-terraform"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "scribble-lc-terraform"

  image_id        = "ami-0e472933a1395e172"
  instance_type   = "m5.2xlarge"
  key_name        = "us-west-2"
  security_groups = [data.aws_security_group.default.id]
  load_balancers  = [module.elb.this_elb_id]
  user_data       = <<EOF
#!/bin/bash
yum update -y
yum install ruby -y
yum install wget -y

CODEDEPLOY_BIN="/opt/codedeploy-agent/bin/codedeploy-agent"
$CODEDEPLOY_BIN stop
sudo yum erase codedeploy-agent -y

cd /home/ec2-user
wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install

chmod +x ./install
./install auto
EOF

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "scribble-asg-terraform"
  vpc_zone_identifier       = data.aws_subnet_ids.all.ids
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  iam_instance_profile      = aws_iam_instance_profile.codedeploy-instance-profile-terraform.arn
}

######
# ELB
######
module "elb" {
  source = "terraform-aws-modules/elb/aws"

  name = "scribble-elb-terraform"

  subnets         = data.aws_subnet_ids.all.ids
  security_groups = [data.aws_security_group.default.id]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}
