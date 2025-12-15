# Références aux variables
variable "project_id" {}
variable "region" { default = "europe-west1" }

# Configuration du Fournisseur Google
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Cluster GKE Autopilot (Workload Identity activé par défaut)
resource "google_container_cluster" "primary" {
  name                     = "mon-cluster-tf"
  location                 = var.region
  deletion_protection      = false
  enable_autopilot         = true
  # Le bloc workload_identity_config n'est pas nécessaire pour définir l'espace de nom
  # dans les clusters Autopilot récents, car il utilise la valeur par défaut.
}

# 2. IAM - Workload Identity

# 2a. Compte de service GCP (GSA)
resource "google_service_account" "app_gsa" {
  account_id   = "app-gsa"
  display_name = "SA pour l'application GKE"
}

# 2b. Établir la Confiance : Permettre au KSA (Kubernetes SA) d'assumer l'identité du GSA (GCP SA)
# C'est la partie cruciale de Workload Identity.

resource "google_service_account_iam_member" "gsa_binding" {
  service_account_id = google_service_account.app_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/app-ksa]"
}