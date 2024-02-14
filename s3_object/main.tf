variable "bucket_id" {}
variable "folder_name" {}

resource "aws_s3_object" "src_code" {
  bucket = var.bucket_id
  for_each = fileset("${var.folder_name}", "**/*.*")
  key = each.value
  source = "${var.folder_name}/${each.value}"
  content_type = each.value
}