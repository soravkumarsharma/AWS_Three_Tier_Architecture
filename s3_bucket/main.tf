variable "bucket_name" {}

output "bucket_id" {
  value = aws_s3_bucket.my_bucket.id
}
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

