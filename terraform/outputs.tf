output "gsa_email" {
  value = google_service_account.app_gsa.email
  description = "Email du GSA à utiliser pour l'annotation K8s"
}