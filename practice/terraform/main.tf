# EKS クラスタを作成します
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.subnet_ids
  cluster_endpoint_public_access = true

  # クラスタの作成者を管理者として登録します
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    # CoreDNS は Fargate で動作するように設定します
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        computeType = "fargate"
      })
    }
    # # NOTE: 検証では Fargate だけを使うので、kube-proxy と vpc-cni アドオンは不要です
    # # see.
    # # - https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/managing-kube-proxy.html
    # # - https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/alternate-cni-plugins.html
    # kube-proxy = {
    #   most_recent = true
    # }
    # vpc-cni = {
    #   most_recent = true
    # }
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        },
        {
          namespace = "keda"
        },
        {
          namespace = var.namespace
        },
      ]
    }
  }

  # EKS でサポートされているコントロールプレーンのすべてのログを CloudWatch Logs に送信します
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# SQS キューを作成します
resource "aws_sqs_queue" "myapp" {
  name = format("%s-myapp", var.cluster_name)
}

# keda-operator ServiceAccount の IRSA を作成します
resource "aws_iam_role" "keda_operator" {
  name = format("%s-keda-operator", module.eks.cluster_name)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:keda:keda-operator",
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com",
          }
        }
      }
    ]
  })
}

# keda-operator IRSA が SQS の属性情報を取得するための IAM ポリシーを作成します
resource "aws_iam_policy" "keda_operator" {
  name = format("%s-keda-operator", module.eks.cluster_name)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # SQS の属性情報取得を許可します
      # NOTE: TriggerAuthentication の spec.podIdentity.identityOwner = "operator" の場合に必要となります
      {
        Effect   = "Allow"
        Action   = ["sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.myapp.arn
      },
      # myapp IAM ロールへの sts:AssumeRole を許可します
      # NOTE: TriggerAuthentication の spec.podIdentity.identityOwner = "workload" の場合に必要となります
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.myapp.arn
      },
      # sqs-scaler IAM ロールへの sts:AssumeRole を許可します
      # NOTE: TriggerAuthentication の spec.podIdentity.roleArn を指定する場合に必要となります
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.sqs_scaler.arn
      }
    ]
  })
}

# IAM ポリシーを keda-operator IRSA にアタッチします
resource "aws_iam_role_policy_attachment" "keda_operator" {
  role       = aws_iam_role.keda_operator.name
  policy_arn = aws_iam_policy.keda_operator.arn
}

# myapp ServiceAccount の IRSA を作成します
resource "aws_iam_role" "myapp" {
  name = format("%s-myapp", module.eks.cluster_name)
  # managed_policy_arns = [aws_iam_policy.myapp.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:${var.namespace}:myapp",
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com",
          }
        }
      },
      # keda-operator ロールに対して sts:AssumeRole を許可します
      # NOTE: TriggerAuthentication の spec.identityOwner = "workload" の場合に必要となります
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.keda_operator.arn
        },
      }
    ]
  })
}

# myapp IRSA が SQS を操作するための IAM ポリシーを作成します
resource "aws_iam_policy" "myapp" {
  name = format("%s-myapp", module.eks.cluster_name)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:*"] # myapp では SQS を操作する、という想定です
        Resource = aws_sqs_queue.myapp.arn
      }
    ]
  })
}

# myapp IRSA に IAM ポリシーをアタッチします
resource "aws_iam_role_policy_attachment" "myapp" {
  role       = aws_iam_role.myapp.name
  policy_arn = aws_iam_policy.myapp.arn
}

# AWS SQS Queue Scaler がキューのメッセージ数を取得するための IAM Role を作成します
resource "aws_iam_role" "sqs_scaler" {
  name = format("%s-sqs-scaler", module.eks.cluster_name)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # keda-operator ロールに対して sts:AssumeRole を許可します
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.keda_operator.arn
        }
      }
    ]
  })
}

# SQS の属性情報を取得するための IAM ポリシーを作成します
resource "aws_iam_policy" "sqs_scaler" {
  name = format("%s-sqs-scaler", module.eks.cluster_name)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.myapp.arn
      },
    ]
  })
}

# sqs-scaler IAM Role に IAM ポリシーをアタッチします
resource "aws_iam_role_policy_attachment" "sqs_scaler" {
  role       = aws_iam_role.sqs_scaler.name
  policy_arn = aws_iam_policy.sqs_scaler.arn
}
