###################### External Ingress Controller ######################

resource "helm_release" "nginx_ingress_controller_external" {
  count = contains(local.var.flags, "install_nginx_ingress_controller_external") ? 1 : 0

  name  = local.names.ingress_nginx_external
  chart = "./helm/ingress-nginx"

  timeout = 20 * 60 # 20min

  reset_values = true
  wait         = true

  set {
    name  = "vpcCIDR"
    value = local.var.network.vpc.cidr
  }

  set {
    name = "certARN"
    value = "arn:aws:acm:eu-west-1:125378330806:certificate/a8780710-6043-4314-baaa-51a7c7dceefc"
  }

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer,
  ]
}

data "kubernetes_service" "ingress_nginx_controller_external" {
  count = contains(local.var.flags, "install_nginx_ingress_controller_external") ? 1 : 0

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [
    helm_release.nginx_ingress_controller_external
  ]
}
