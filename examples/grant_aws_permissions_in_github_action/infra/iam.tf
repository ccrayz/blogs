

data "external" "script_result" {
  program = ["bash", "./thumprint.sh"]
}

resource "aws_iam_openid_connect_provider" "github_idp" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.external.script_result.result["thumbprint"]
  ]
}

resource "aws_iam_role" "github_action_role" {
  name = "github_action_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal : {
          Federated : aws_iam_openid_connect_provider.github_idp.arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          StringLike : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:ccrayz/*",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_action_policy" {
  name        = "github-action-ecr-read-push"
  description = "Allow ECR read and push"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:ap-northeast-2:${var.account_id}:repository/example-ecr"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "github_action_role_attachment" {
  name       = "github-action-role-attachment"
  roles      = [aws_iam_role.github_action_role.name]
  policy_arn = aws_iam_policy.github_action_policy.arn
}
