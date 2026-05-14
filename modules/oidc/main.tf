resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "gha" {
  for_each = var.roles

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${each.value.repo}:ref:refs/heads/${each.value.branch}"
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "gha" {
  for_each = {
    for pair in flatten([
      for role_name, role in var.roles : [
        for arn in role.policy_arns : {
          key        = "${role_name}:${arn}"
          role_name  = role_name
          policy_arn = arn
        }
      ]
    ]) : pair.key => pair
  }

  role       = aws_iam_role.gha[each.value.role_name].name
  policy_arn = each.value.policy_arn
}
