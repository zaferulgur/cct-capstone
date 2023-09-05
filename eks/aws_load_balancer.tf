module "iam_eks_role_lb" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.23.0"

  role_name                              = local.names.iam_eks_role_lb
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:${local.names.aws_load_balancer}"]
    }
  }

  depends_on = [
    module.eks
  ]
}

resource "kubernetes_service_account" "aws_load_balancer" {
  metadata {
    name      = local.names.aws_load_balancer
    namespace = local.const.kube_system_ns

    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_role_lb.iam_role_arn
    }
  }

  automount_service_account_token = true

  depends_on = [
    module.iam_eks_role_lb
  ]
}

resource "helm_release" "aws_load_balancer" {
  name       = local.names.aws_load_balancer
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = local.const.kube_system_ns
  version    = "1.4.8"

  reset_values = true
  wait         = true

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = local.names.aws_load_balancer
  }

  depends_on = [
    module.eks,
    kubernetes_service_account.aws_load_balancer,
  ]
}
