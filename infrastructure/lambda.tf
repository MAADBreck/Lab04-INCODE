data "archive_file" "upload_zip" {
  type        = "zip"
  source_dir  = "../src/upload"
  output_path = "upload.zip"
}

data "archive_file" "crop_zip" {
  type        = "zip"
  source_dir  = "../src/crop"
  output_path = "crop.zip"
}

resource "aws_security_group" "lambda_sg" {
  name        = "sg-lambda-${var.environment}"
  vpc_id      = aws_vpc.main.id
  egress { 
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_lambda_function" "upload_lambda" {
  filename         = data.archive_file.upload_zip.output_path
  function_name    = "upload-lambda-${var.environment}"
  role             = aws_iam_role.upload_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30
  memory_size      = 256
  source_code_hash = data.archive_file.upload_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private[0].id, aws_subnet.private[1].id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.images.bucket
      UPLOAD_PREFIX = "uploads/"
    }
  }
}

resource "aws_lambda_function" "crop_lambda" {
  filename         = data.archive_file.crop_zip.output_path
  function_name    = "crop-lambda-${var.environment}"
  role             = aws_iam_role.crop_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 60
  memory_size      = 512
  source_code_hash = data.archive_file.crop_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private[0].id, aws_subnet.private[1].id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.images.bucket
      PROCESSED_PREFIX = "processed/"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.crop_lambda.arn
  batch_size       = 5
}