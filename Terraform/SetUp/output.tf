output "cd_user_access_key_id" {
  description = "aws acces key for CD User"
  value       = aws_iam_access_key.cd.id
}
output "cd_user_access_secret" {
  description = "Access Key secret for CD user"
  value       = aws_iam_access_key.cd.secret
  sensitive   = true
}
#  description = "Json Document Policy for our CD User"
#  value       = data.aws_iam_policy_document.tf_backend.json

output "ECR" {
  description = "ECR url "
  value       = aws_ecr_repository.ECR.repository_url

}
output "ECR_Proxy" {
  description = "ECR URL For Proxy Image "
  value       = aws_ecr_repository.ECR_Proxy.repository_url

}
