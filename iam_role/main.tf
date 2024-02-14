variable "iam_role_name" {}
output "instance_profile_name" {
  value = aws_iam_instance_profile.app_instance_profile.name 
}
resource "aws_iam_role" "my_iam_role" {
  name = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_policy_attach" {
  name       = "s3_policy"
  roles      = [aws_iam_role.my_iam_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "ssm_policy_attach" {
  name       = "ssm_policy"
  roles      = [aws_iam_role.my_iam_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app_instance_profile" {
    name = "app_instance_profile"
    role = aws_iam_role.my_iam_role.name
}