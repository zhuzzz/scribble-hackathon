variable "env" {
  description = "Depolyment environment"
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "repository_branch" {
  description = "Repository branch to connect to"
  default     = "yannan-local-dev"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  default     = "zhuzzz"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "scribbles"
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "codepipeline-artifact-bucket-scribble"
}

variable "github_token" {
}