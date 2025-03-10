#==============================================================================
# COMMONS
#==============================================================================
module "commons" {
  source       = "../commons"
  project_name = var.project_name
  environment  = var.environment
}

locals {
  name = "${var.project_name}-${var.environment}"
}

#--------------------------------------------------------------------------
# Nginx Ingress
#--------------------------------------------------------------------------
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.7.1"
  timeout          = 900
  wait             = true
  values = [
    file("${path.module}/values/nginx-ingress-values.yaml")
  ]
}

#--------------------------------------------------------------------------
# Cert Manager
#--------------------------------------------------------------------------
# D'abord installer cert-manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.13.3"
  create_namespace = true

  values = [
    templatefile("${path.module}/values/cert-manager.yaml", {})
  ]

  # Configuration des CRDs et Webhooks
  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "webhook.timeoutSeconds"
    value = "10" # Réduit de 30 à 10 secondes
  }

  # Gestion des CRDs bloquées
  set {
    name  = "extraArgs[0]"
    value = "--enable-certificate-owner-ref=true"
  }

  set {
    name  = "extraArgs[1]"
    value = "--dns01-recursive-nameservers-only"
  }

  # Configuration des webhooks pour éviter les blocages
  set {
    name  = "webhook.mutating.failurePolicy"
    value = "Ignore" # Plus permissif lors du destroy
  }

  set {
    name  = "webhook.validating.failurePolicy"
    value = "Ignore" # Plus permissif lors du destroy
  }

  # Paramètres de gestion du cycle de vie
  cleanup_on_fail = true
  force_update    = true
  recreate_pods   = false # Pas besoin pendant le destroy

  # Gestion du timeout et de l'attente
  timeout = 300 # Réduit de 600 à 300 secondes
  wait    = true
  atomic  = false # Évite d'attendre la finalisation complète

  depends_on = [
    helm_release.nginx_ingress
  ]

  # Provisioner pour nettoyer les CRDs lors du destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl delete crd -l app.kubernetes.io/instance=cert-manager --force --grace-period=0 || true
      kubectl delete validatingwebhookconfiguration -l app.kubernetes.io/instance=cert-manager --force --grace-period=0 || true
      kubectl delete mutatingwebhookconfiguration -l app.kubernetes.io/instance=cert-manager --force --grace-period=0 || true
      kubectl delete namespace cert-manager --force --grace-period=0 || true
    EOT
  }
}

# Attente plus longue pour s'assurer que les CRDs sont bien installées
resource "time_sleep" "wait_for_cert_manager_ready" {
  depends_on      = [helm_release.cert_manager]
  create_duration = "90s" # Augmenté à 90 secondes
}

#--------------------------------------------------------------------------
# PROMETHEUS (DONE)
#--------------------------------------------------------------------------

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack" # Change pour inclure Grafana
  namespace        = "monitoring"
  version          = "45.7.1"
  create_namespace = true

  values = [
    templatefile("${path.module}/values/prometheus-values.yaml", {
      domain_name      = var.domain_name
      grafana_password = var.grafana_password
      environment      = var.environment
    })
  ]
  timeout = 600
  wait    = true
  depends_on = [
    helm_release.nginx_ingress,
    time_sleep.wait_for_cert_manager_ready
  ]
}

#--------------------------------------------------------------------------
# VELOERO (DONE)
#--------------------------------------------------------------------------
# Namespace Velero
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
    labels = {
      name = "velero"
    }
  }
}

resource "helm_release" "velero" {
  name             = "velero"
  repository       = "https://vmware-tanzu.github.io/helm-charts"
  chart            = "velero"
  version          = "5.0.2"
  namespace        = kubernetes_namespace.velero.metadata[0].name
  create_namespace = false

  # Augmentation du timeout et attente active
  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    templatefile("${path.module}/values/velero-values.yaml", {
      bucket_name     = var.velero_bucket_name
      aws_region      = var.aws_region
      velero_role_arn = var.velero_role_arn
    })
  ]
  # Force la recréation si les values changent
  recreate_pods = true
  depends_on = [
    kubernetes_namespace.velero,
    helm_release.nginx_ingress
  ]
}

#--------------------------------------------------------------------------
# FLUENTD
#--------------------------------------------------------------------------
# Namespace Fluentd
resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
    labels = {
      name = "logging"
    }
  }
}

# Release Fluentd avec version mise à jour
resource "helm_release" "fluentd" {
  name             = "fluentd"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluentd"
  namespace        = kubernetes_namespace.logging.metadata[0].name
  version          = "0.5.0" # Version plus récente
  create_namespace = false
  timeout          = 600
  wait             = false
  recreate_pods    = true # Pour debug
  force_update     = true

  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "podSecurityContext.enabled"
    value = "true"
  }
  values = [
    templatefile("${path.module}/values/fluentd-values.yaml", {
      logs_bucket      = "${var.project_name}-${var.environment}-logs-2" # Correspond au nom du bucket
      aws_region       = var.aws_region
      fluentd_role_arn = var.fluentd_role_arn
    })
  ]

  depends_on = [
    kubernetes_namespace.logging
  ]
}


