resource "aws_codepipeline" "scribble_pipeline" {
  name     = "scribble-pipeline-terraform"
  role_arn = aws_iam_role.scribble_pipeline_role.arn
  tags = {
    Environment = var.env
  }

  artifact_store {
    location = aws_s3_bucket.artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "Branch"               = var.repository_branch
        "Owner"                = var.repository_owner
        "PollForSourceChanges" = "false"
        "Repo"                 = var.repository_name
        OAuthToken             = var.github_token
      }

      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
          ]
        )
        "ProjectName" = "scribble-codebuild-terraform"
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }

//  stage {
//    name = "Deploy"
//
//    action {
//      category = "Deploy"
//      configuration = {
//        "BucketName" = aws_s3_bucket.static_web_bucket.bucket
//        "Extract"    = "true"
//      }
//      input_artifacts = [
//        "BuildArtifact",
//      ]
//      name             = "Deploy"
//      output_artifacts = []
//      owner            = "AWS"
//      provider         = "S3"
//      run_order        = 1
//      version          = "1"
//    }
//  }
}
