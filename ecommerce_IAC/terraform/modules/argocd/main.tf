resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.0"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  timeout          = 900
  atomic           = true

  values = [
    templatefile("${path.module}/template/values.yaml", {
      domain_name           = var.domain_name
      gitlab_repo_url       = var.gitlab_repo_url
      app_repository_secret = var.app_repository_secret # La clé SSH est déjà le contenu
    })
  ]
}

resource "kubernetes_secret" "gitlab_ssh" {
  metadata {
    name      = "argocd-repo-secret"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"
  data = {
    type          = "git"
    url           = var.gitlab_repo_url
    sshPrivateKey = var.app_repository_secret
  }

  depends_on = [helm_release.argocd]
}

resource "helm_release" "argocd-apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "argocd"
  version    = "2.0.0"
  values = [
    templatefile("${path.module}/template/application_values.yaml", {
      gitlab_repo_url = var.gitlab_repo_url
      environment     = var.environment
    })
  ]
  depends_on = [helm_release.argocd, kubernetes_secret.gitlab_ssh]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}
