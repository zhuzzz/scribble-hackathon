
resource "aws_s3_bucket" "static_web_bucket" {
  bucket = var.static_web_bucket_name

}

resource "aws_s3_bucket" "artifacts_bucket" {
  bucket        = var.artifacts_bucket_name
  force_destroy = true
}