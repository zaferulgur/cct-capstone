resource "kubernetes_cluster_role" "view-nodes" {
  metadata {
    name = "view-nodes"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "view-rbac" {
  metadata {
    name = "view-rbac"
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources = [
      "clusterrolebindings",
      "clusterroles",
      "rolebindings",
      "roles",
    ]
    verbs = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "view-secrets" {
  metadata {
    name = "view-secrets"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "zu-view-all" {
  metadata {
    name = "zu-view-all"
  }

  rule {
    api_groups = [""]
    resources  = [ "bindings", "componentstatuses", "configmaps", "endpoints", "events", "limitranges", "namespaces", "namespaces/finalize", "namespaces/status", "nodes", "nodes/proxy", "nodes/status",  "persistentvolumeclaims", "persistentvolumeclaims/status", "persistentvolumes", "persistentvolumes/status", "pods", "pods/attach", "pods/binding", "pods/eviction", "pods/exec", "pods/log", "pods/proxy",  "pods/status", "podtemplates", "replicationcontrollers", "replicationcontrollers/scale", "replicationcontrollers/status", "resourcequotas", "resourcequotas/status", "serviceaccounts", "services", "services/proxy", "services/status" ]
    verbs      = [ "get", "list", "watch" ]
  }
}

resource "kubernetes_cluster_role" "zu-manage-apps" {
  metadata {
    name = "zu-manage-apps"
  }

  rule {
    api_groups = [ "apps" ]
    resources  = [ "controllerrevisions", "daemonsets", "daemonsets/status", "deployments", "deployments/scale", "deployments/status", "replicasets", "replicasets/scale", "replicasets/status", "statefulsets", "statefulsets/scale", "statefulsets/status" ]
    verbs      = [ "get", "list", "watch", "create", "patch", "update" ]
  }
}
