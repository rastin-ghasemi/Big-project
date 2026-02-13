output "debug_images" {
  value = {
    ecr_app_image   = var.ecr_app_image
    ecr_proxy_image = var.ecr_proxy_image
  }
  sensitive = false
}

output "Domain_name" {
  value = aws_route53_record.app.fqdn

}