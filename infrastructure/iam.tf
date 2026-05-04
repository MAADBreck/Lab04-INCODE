
resource "aws_iam_role" "upload_role" {
  name = "upload-lambda-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "upload_vpc" {
  role       = aws_iam_role.upload_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "upload_s3" {
  name = "upload-s3-policy-${var.environment}"
  role = aws_iam_role.upload_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ 
      Action = ["s3:PutObject"], 
      Effect = "Allow", 
      Resource = "${aws_s3_bucket.images.arn}/uploads/*" 
    }]
  })
}

resource "aws_iam_role" "crop_role" {
  name = "crop-lambda-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "crop_vpc" {
  role       = aws_iam_role.crop_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "crop_s3_sqs" {
  name = "crop-s3-sqs-policy-${var.environment}"
  role = aws_iam_role.crop_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Action = ["s3:GetObject"], Effect = "Allow", Resource = "${aws_s3_bucket.images.arn}/uploads/*" },
      { Action = ["s3:PutObject"], Effect = "Allow", Resource = "${aws_s3_bucket.images.arn}/processed/*" },
      { 
        Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ChangeMessageVisibility"], 
        Effect = "Allow", 
        Resource = aws_sqs_queue.image_queue.arn 
      }
    ]
  })
}