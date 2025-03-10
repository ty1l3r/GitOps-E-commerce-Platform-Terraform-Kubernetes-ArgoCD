#-----------------------------------
# Outputs Nginx Ingress
#-----------------------------------
output "nginx_ingress_hostname" {
  description = "Hostname du Load Balancer Nginx Ingress"
  value       = helm_release.nginx_ingress.metadata[0].name
}

output "nginx_ingress_namespace" {
  description = "Namespace de Nginx Ingress"
  value       = helm_release.nginx_ingress.namespace
}

#-----------------------------------
# Outputs Cert Manager
#-----------------------------------
output "cert_manager_namespace" {
  description = "Namespace de Cert Manager"
  value       = helm_release.cert_manager.namespace
}

#-----------------------------------
# Outputs Prometheus/Grafana
#-----------------------------------
output "prometheus_namespace" {
  description = "Namespace de Prometheus/Grafana"
  value       = helm_release.prometheus.namespace
}

output "grafana_url" {
  description = "URL de Grafana"
  value       = "https://grafana.${var.domain_name}"
}

#-----------------------------------
# Outputs Velero
#-----------------------------------
output "velero_namespace" {
  description = "Namespace de Velero"
  value       = kubernetes_namespace.velero.metadata[0].name
}

output "velero_release_name" {
  description = "Nom de la release Velero"
  value       = helm_release.velero.name
}

output "velero_status" {
  description = "Statut de l'installation Velero"
  value       = helm_release.velero.status
}

output "velero_backup_location" {
  description = "Location des backups Velero"
  value       = "${var.velero_bucket_name}/velero"
}

#-----------------------------------
# Outputs Fluentd
#-----------------------------------
output "fluentd_namespace" {
  description = "Namespace de Fluentd"
  value       = kubernetes_namespace.logging.metadata[0].name
}

output "fluentd_release_name" {
  description = "Nom de la release Fluentd"
  value       = helm_release.fluentd.name
}
output "velero_service_account" {
  description = "Nom du service account Velero"
  value       = "velero" # C'est le nom par défaut utilisé dans les values
}

