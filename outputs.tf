output "API_Server_Endpoint" {
  value = module.eks.cluster_endpoint
}

output "github_action_role" {
  value = aws_iam_role.github_action_role.arn
}
