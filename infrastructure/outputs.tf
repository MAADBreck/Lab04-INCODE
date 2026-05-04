output "api_url" {
  description = "La URL pública para subir imágenes"
  value       = "${aws_apigatewayv2_api.api.api_endpoint}/upload"
}

output "s3_bucket_name" {
  description = "El nombre de tu bucket donde se guardan las fotos"
  value       = aws_s3_bucket.images.bucket
}