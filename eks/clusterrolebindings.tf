resource "kubernetes_cluster_role_binding" "viewonly" {
  metadata {
    name = "viewonly-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = local.names.k8s_rbac_viewonly_group
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    name      = local.names.terraform_viewonly_group
    kind      = "Group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "view-nodes" {
  metadata {
    name = "view-nodes-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view-nodes"
  }
  subject {
    kind      = "Group"
    name      = local.names.k8s_rbac_viewonly_group
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    name      = local.names.terraform_viewonly_group
    kind      = "Group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "view-rbac" {
  metadata {
    name = "view-rbac-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view-rbac"
  }
  subject {
    name      = local.names.terraform_viewonly_group
    kind      = "Group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "view-secrets" {
  metadata {
    name = "view-secrets-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view-secrets"
  }
  subject {
    name      = local.names.terraform_viewonly_group
    kind      = "Group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "admin-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "Group"
    name      = local.names.k8s_rbac_admin_group
    api_group = "rbac.authorization.k8s.io"
  }
}
