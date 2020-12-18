// service role for codepipeline
resource "aws_iam_role" "scribble_pipeline_role" {

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codepipeline.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "scribble-pipeline-role-${var.env}"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "scribble_pipeline_policy" {
  description = "Policy used in trust relationship with CodePipeline"
  name        = "scribble-pipeline-policy-${var.env}"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement : [
        {
          Action : [
            "iam:PassRole"
          ],
          Resource : "*",
          Effect : "Allow"
        },
        {
          Action = [
            "s3:*",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action : [
            "codepipeline:*",
            "iam:ListRoles",
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild",
            "codestar-connections:*",
            "iam:PassRole",
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision"
          ],
          Resource : "*",
          Effect : "Allow"
        },
      ],
      "Version" : "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "pipeline_policy_attachment" {
  role       = aws_iam_role.scribble_pipeline_role.name
  policy_arn = aws_iam_policy.scribble_pipeline_policy.arn
}

// service role for codebuild
resource "aws_iam_role" "scribble_codebuild_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "scribble-codebuild-role-${var.env}"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "scribble_build_policy" {
  description = "Policy used in trust relationship with CodeBuild (${var.env})"
  name        = "scribble-codebuild-policy-${var.env}"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" = "Allow",
          "Action" = [
            "s3:*"
          ],
          "Resource" = [
            "arn:aws:s3:::*",
            "arn:aws:s3:::*"
          ]
        },
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:logs:*"
        }
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role_policy_attachment" "build_policy_attachment" {
  role       = aws_iam_role.scribble_codebuild_role.name
  policy_arn = aws_iam_policy.scribble_build_policy.arn
}

// service role for codedeploy
resource "aws_iam_role" "scribble_codedeploy_role" {
  name = "scribble-codedeploy-role-terraform"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.scribble_codedeploy_role.name
}

// instance profile
resource "aws_iam_instance_profile" "codedeploy-instance-profile-terraform" {
  name = "codedeploy-instance-profile-terraform"
  role = aws_iam_role.codeploy_instance_profile_role.name
}

resource "aws_iam_role" "codeploy_instance_profile_role" {
  name = "codedeploy-instance-profile-terraform"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "scribble_codedeploy_instance_profile_policy" {
  name = "scribble-codedeploy-instance-profile-policy"
  path = "/"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "s3:Get*",
            "s3:List*"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "instance_profile_policy_attachment" {
  role       = aws_iam_role.codeploy_instance_profile_role.name
  policy_arn = aws_iam_policy.scribble_codedeploy_instance_profile_policy.arn
}