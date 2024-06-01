resource "aws_iam_openid_connect_provider" "default" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_action_role" {
  name = "github-action-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.default.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:vampconnoisseur/autonomis-charts:ref:refs/heads/main",
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

  tags = {
    Name = "github-action-role"
  }
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.github_action_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeCluster"
        ],
        "Resource" : [
          "${module.eks.cluster_arn}"
        ]
      }
    ]
  })
}

# resource "aws_eks_access_entry" "example" {
#   cluster_name  = module.eks.cluster_name
#   principal_arn = aws_iam_role.github_action_role.arn
#   type          = "STANDARD"
# }

# resource "aws_eks_access_policy_association" "example" {
#   cluster_name  = module.eks.cluster_name
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#   principal_arn = aws_iam_user.github_action_role.arn

#   access_scope {
#     type = "cluster"
#   }
# }

# resource "aws_iam_role" "ebs_csi_driver_role" {
#   name = "eks-ebs-csi-driver-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Principal": {
#         "Federated": "${module.eks.oidc_provider_arn}"
#       },
#       "Condition": {
#         "StringEquals": {
#           "${module.eks.oidc_provider}:aud": [
#             "sts.amazonaws.com"
#           ]
#         }
#       }
#     }
#   ]
# }

# EOF

#   tags = {
#     Name = "eks-ebs-csi-driver-role"
#   }
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
#   role       = aws_iam_role.ebs_csi_driver_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name = module.eks.cluster_name

#   addon_name = "aws-ebs-csi-driver"

#   depends_on = [
#     aws_iam_role.ebs_csi_driver_role,
#   ]

#   service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
# }

# resource "helm_release" "autonomis-one" {
#   name       = "autonomis"
#   repository = "https://vampconnoisseur.github.io/autonomis-charts/charts"
#   chart      = "autonomis-charts"
#   namespace  = "default"
# }

# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   namespace  = "monitoring"
# }
