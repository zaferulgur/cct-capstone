module "iam_eks_role_cluster_autoscaler" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.23.0"

  role_name                        = local.names.iam_eks_role_cluster_autoscaler
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:${local.names.cluster_autoscaler_fullname}"]
    }
  }

  depends_on = [
    module.eks
  ]
}

resource "helm_release" "cluster_autoscaler" {
  name         = local.names.cluster_autoscaler
  repository   = "https://kubernetes.github.io/autoscaler"
  chart        = "cluster-autoscaler"
  namespace    = local.const.kube_system_ns
  version      = "9.23.2"
  reset_values = true
  wait         = true
  # verify       = false

  # auto-scale: https://aws.github.io/aws-eks-best-practices/cluster-autoscaling/#reducing-the-scan-interval
  set {
    name  = "extraArgs.scan-interval"
    value = "1m"
  }

  set {
    name  = "fullnameOverride"
    value = local.names.cluster_autoscaler_fullname
  }

  set {
    name  = "image.tag"
    value = "v${local.var.cluster_version}.1"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_eks_role_cluster_autoscaler.iam_role_arn
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "awsRegion"
    value = local.var.region
  }

  depends_on = [
    module.eks
  ]
}
