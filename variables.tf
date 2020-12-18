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
  default     = "Scribbles-local"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  default     = "niveram95"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "Scribbles-source"
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "codepipeline-artifact-scribble"
}