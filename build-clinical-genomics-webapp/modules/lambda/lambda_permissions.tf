# Author Dolapo Ajayi

# IAM role for Lambda to manage EC2 instances
resource "aws_iam_role" "lambda_ec2_control" {
  name = "lambda-ec2-control-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_ec2_policy" {
  name = "lambda-ec2-control-policy"
  role = aws_iam_role.lambda_ec2_control.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}
