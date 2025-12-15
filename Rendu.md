1. Configuration de Google Cloud

J'ai crée un projet via l'interface web de google cloud 

2. Création de l'application Python Simpliste

```
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return '<h1>Bienvenue sur mon application Python conteneurisée sur GKE !</h1>'

if __name__ == '__main__':
    # Écoute sur toutes les interfaces (nécessaire pour Docker)
    app.run(host='0.0.0.0', port=8080)
```

3. Conteneurisation (Docker)

```
# Utilise une image de base Python légère
FROM python:3.9-slim

# Définit le répertoire de travail dans le conteneur
WORKDIR /app

# Copie le fichier requirements.txt et installe les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie le reste du code source
COPY . .

# Expose le port par lequel l'application s'exécutera
EXPOSE 8080

# Commande à exécuter lorsque le conteneur démarre
CMD ["python", "app.py"]
```

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> docker build -t mon-app-python:v1 .
[+] Building 14.1s (10/10) FINISHED                                                                docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                               0.1s
 => => transferring dockerfile: 520B                                                                               0.0s
 => [internal] load metadata for docker.io/library/python:3.9-slim                                                 3.0s
 => [internal] load .dockerignore                                                                                  0.1s
 => => transferring context: 2B                                                                                    0.0s
 => [1/5] FROM docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf  2.8s
 => => resolve docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf  0.1s
 => => sha256:ea56f685404adf81680322f152d2cfec62115b30dda481c2c450078315beb508 251B / 251B                         0.3s
 => => sha256:fc74430849022d13b0d44b8969a953f842f59c6e9d1a0c2c83d710affa286c08 13.88MB / 13.88MB                   1.4s
 => => sha256:b3ec39b36ae8c03a3e09854de4ec4aa08381dfed84a9daa075048c2e3df3881d 1.29MB / 1.29MB                     0.9s
 => => extracting sha256:b3ec39b36ae8c03a3e09854de4ec4aa08381dfed84a9daa075048c2e3df3881d                          0.5s
 => => extracting sha256:fc74430849022d13b0d44b8969a953f842f59c6e9d1a0c2c83d710affa286c08                          1.0s
 => => extracting sha256:ea56f685404adf81680322f152d2cfec62115b30dda481c2c450078315beb508                          0.1s
 => [internal] load build context                                                                                  0.1s
 => => transferring context: 914B                                                                                  0.0s
 => [2/5] WORKDIR /app                                                                                             0.8s
 => [3/5] COPY requirements.txt .                                                                                  0.1s
 => [4/5] RUN pip install --no-cache-dir -r requirements.txt                                                       5.1s
 => [5/5] COPY . .                                                                                                 0.2s
 => exporting to image                                                                                             1.7s
 => => exporting layers                                                                                            0.9s
 => => exporting manifest sha256:daf31b53b3757eb1e8c7436ea0cb9f0137cdbc63197d03f20ee75aed612bebd5                  0.0s
 => => exporting config sha256:bfb1fb356f93d9f9e9c666d5451718027cc96b323efba9a8a9f270d54a01c4d1                    0.0s
 => => exporting attestation manifest sha256:10e1728f5f0e8c0004fdd771fa85ff713e62457b522987eb68879ebdcf1ef1b7      0.1s
 => => exporting manifest list sha256:0bfb07f3ec88c7d2df7e777ec5a3abe3c16afe88c0991903982d54810335247f             0.0s
 => => naming to docker.io/library/mon-app-python:v1                                                               0.0s
 => => unpacking to docker.io/library/mon-app-python:v1                                                            0.5s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/38yslwbt35511567141ki72ls
PS C:\Users\Milanese\TP-CLOUD\TP-Final> docker run -p 8080:8080 mon-app-python:v1
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8080
 * Running on http://172.17.0.2:8080
Press CTRL+C to quit
172.17.0.1 - - [15/Dec/2025 09:25:39] "GET / HTTP/1.1" 200 -
172.17.0.1 - - [15/Dec/2025 09:25:39] "GET /favicon.ico HTTP/1.1" 404 -
```

4. Registre (Artifact Registry) et Push

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> gcloud artifacts repositories create mon-depot-docker --repository-format=docker --location=europe-west1 --description="Dépôt Docker pour l'application Python"
Create request issued for: [mon-depot-docker]
Waiting for operation [projects/tp-kubernetes-gke-479308/locations/europe-west1/operations/18c8c6d3-840e-48e2-bd4c-d131
b4d14366] to complete...done.
Created repository [mon-depot-docker].


Updates are available for some Google Cloud CLI components.  To install them,
please run:
  $ gcloud components update



To take a quick anonymous survey, run:
  $ gcloud survey
```

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> gcloud auth configure-docker europe-west1-docker.pkg.dev
WARNING: Your config file at [C:\Users\Milanese\.docker\config.json] contains these credential helper entries:

{
  "credHelpers": {
    "europe-west1-docker.pkg.dev": "gcloud"
  }
}
Adding credentials for: europe-west1-docker.pkg.dev
gcloud credential helpers already registered correctly.
```

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> docker build -t mon-app-python:v1 .
[+] Building 2.6s (10/10) FINISHED                                                                 docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 520B                                                                               0.0s
 => [internal] load metadata for docker.io/library/python:3.9-slim                                                 2.2s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 2B                                                                                    0.0s
 => [1/5] FROM docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf  0.0s
 => => resolve docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf  0.0s
 => [internal] load build context                                                                                  0.0s
 => => transferring context: 6.34kB                                                                                0.0s
 => CACHED [2/5] WORKDIR /app                                                                                      0.0s
 => CACHED [3/5] COPY requirements.txt .                                                                           0.0s
 => CACHED [4/5] RUN pip install --no-cache-dir -r requirements.txt                                                0.0s
 => [5/5] COPY . .                                                                                                 0.0s
 => exporting to image                                                                                             0.2s
 => => exporting layers                                                                                            0.1s
 => => exporting manifest sha256:7f2b488545725912235bb67e73694cad63e4ff47487db0fa04eaf69febe2f5e4                  0.0s
 => => exporting config sha256:e13b2829dc5f052f6513cceabe3b5a0ce360bd29ee52f207f8cefc01955009ed                    0.0s
 => => exporting attestation manifest sha256:ad04200a4fd9656587fd79e5ba1785f345ace7cf780ead69b820a5b885db32a6      0.0s
 => => exporting manifest list sha256:ca52b689cd5fb2183162be6fa643292697284fd878fa742681be129f5a4b9387             0.0s
 => => naming to docker.io/library/mon-app-python:v1                                                               0.0s
 => => unpacking to docker.io/library/mon-app-python:v1     
```
```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> docker tag mon-app-python:v1 europe-west1-docker.pkg.dev/tp-kubernetes-gke-479308/mon-depot-docker/mon-app-python:v1.0.0
```

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> docker push europe-west1-docker.pkg.dev/tp-kubernetes-gke-479308/mon-depot-docker/mon-app-python:v1.0.0
The push refers to repository [europe-west1-docker.pkg.dev/tp-kubernetes-gke-479308/mon-depot-docker/mon-app-python]
fc7443084902: Pushed
de62622bb4c4: Pushed
38513bd72563: Mounted from vast-maxim-477110-m1/flask-api-repo/flask-api
6cc49d7157ff: Pushed
cdcfa2a33203: Pushed
99d60c74baab: Pushed
1a0a93244e27: Pushed
b3ec39b36ae8: Pushed
ea56f685404a: Pushed
v1.0.0: digest: sha256:ca52b689cd5fb2183162be6fa643292697284fd878fa742681be129f5a4b9387 size: 856
```

4.5.Initilisation de Terraform 

A partir de la je commence a utiliser terraform dans le TP 

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final\terraform> terraform init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/google versions matching "~> 5.0"...
- Installing hashicorp/google v5.45.2...
- Installed hashicorp/google v5.45.2 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
```
PS C:\Users\Milanese\TP-CLOUD\TP-Final\terraform> terraform apply -var="project_id=tp-kubernetes-gke-479308"
google_service_account.app_gsa: Refreshing state... [id=projects/tp-kubernetes-gke-479308/serviceAccounts/app-gsa@tp-kubernetes-gke-479308.iam.gserviceaccount.com]
google_service_account_iam_member.gsa_binding: Refreshing state... [id=projects/tp-kubernetes-gke-479308/serviceAccounts/app-gsa@tp-kubernetes-gke-479308.iam.gserviceaccount.com/roles/iam.workloadIdentityUser/serviceAccount:tp-kubernetes-gke-479308.svc.id.goog[default/app-ksa]]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # google_container_cluster.primary will be created
  + resource "google_container_cluster" "primary" {
      + cluster_ipv4_cidr                        = (known after apply)
      + datapath_provider                        = (known after apply)
      + default_max_pods_per_node                = (known after apply)
      + deletion_protection                      = false
      + enable_autopilot                         = true
      + enable_cilium_clusterwide_network_policy = false
      + enable_intranode_visibility              = true
      + enable_kubernetes_alpha                  = false
      + enable_l4_ilb_subsetting                 = false
      + enable_legacy_abac                       = false
      + enable_multi_networking                  = false
      + enable_shielded_nodes                    = true
      + endpoint                                 = (known after apply)
      + id                                       = (known after apply)
      + label_fingerprint                        = (known after apply)
      + location                                 = "europe-west1"
      + logging_service                          = (known after apply)
      + master_version                           = (known after apply)
      + monitoring_service                       = (known after apply)
      + name                                     = "mon-cluster-tf"
      + network                                  = "default"
      + networking_mode                          = "VPC_NATIVE"
      + node_locations                           = (known after apply)
      + node_version                             = (known after apply)
      + operation                                = (known after apply)
      + private_ipv6_google_access               = (known after apply)
      + project                                  = (known after apply)
      + self_link                                = (known after apply)
      + services_ipv4_cidr                       = (known after apply)
      + subnetwork                               = (known after apply)
      + tpu_ipv4_cidr_block                      = (known after apply)

      + addons_config (known after apply)

      + authenticator_groups_config (known after apply)

      + cluster_autoscaling (known after apply)

      + confidential_nodes (known after apply)

      + cost_management_config (known after apply)

      + database_encryption (known after apply)

      + default_snat_status (known after apply)

      + gateway_api_config (known after apply)

      + identity_service_config (known after apply)

      + ip_allocation_policy (known after apply)

      + logging_config (known after apply)

      + master_auth (known after apply)

      + master_authorized_networks_config (known after apply)

      + mesh_certificates (known after apply)

      + monitoring_config (known after apply)

      + node_config (known after apply)

      + node_pool (known after apply)

      + node_pool_auto_config (known after apply)

      + node_pool_defaults (known after apply)

      + notification_config (known after apply)

      + release_channel (known after apply)

      + security_posture_config (known after apply)

      + service_external_ips_config (known after apply)

      + vertical_pod_autoscaling (known after apply)

      + workload_identity_config (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_container_cluster.primary: Creating...
google_container_cluster.primary: Still creating... [10s elapsed]
google_container_cluster.primary: Still creating... [9m20s elapsed]
google_container_cluster.primary: Creation complete after 9m22s [id=projects/tp-kubernetes-gke-479308/locations/europe-west1/clusters/mon-cluster-tf]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

gsa_email = "app-gsa@tp-kubernetes-gke-479308.iam.gserviceaccount.com"
```

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final\terraform> terraform output gsa_email
"app-gsa@tp-kubernetes-gke-479308.iam.gserviceaccount.com"
```
5. Déploiement (Kubernetes/GKE)

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final\terraform> gcloud container clusters get-credentials mon-cluster-tf --region=europe-west1
Fetching cluster endpoint and auth data.
kubeconfig entry generated for mon-cluster-tf.  
```
```
PS C:\Users\Milanese\TP-CLOUD\TP-Final\terraform> kubectl create serviceaccount app-ksa
serviceaccount/app-ksa created
PS C:\Users\Milanese\TP-CLOUD\TP-Final\terraform> kubectl annotate serviceaccount app-ksa iam.gke.io/gcp-service-account=app-gsa@tp-kubernetes-gke-479308.iam.gserviceaccount.com
serviceaccount/app-ksa annotated
PS C:\Users\Milanese\TP-CLOUD\TP-Final\terraform>
```

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> kubectl apply -f k8s/deployment.yaml
Warning: autopilot-default-resources-mutator:Autopilot updated Deployment default/python-app-deployment: defaulted unspecified 'cpu' resource for containers [python-app-container] (see http://g.co/gke/autopilot-defaults).
deployment.apps/python-app-deployment created
service/python-app-service created
PS C:\Users\Milanese\TP-CLOUD\TP-Final>
```
```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> kubectl get service python-app-service
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
python-app-service   LoadBalancer   34.118.236.203   34.140.215.184   80:31331/TCP   106s
```

```
PS C:\Users\Milanese\TP-CLOUD\TP-Final> curl http://34.140.215.184

Security Warning: Script Execution Risk
Invoke-WebRequest parses the content of the web page. Script code in the web page might be run when the page is
parsed.
      RECOMMENDED ACTION:
      Use the -UseBasicParsing switch to avoid script code execution.

      Do you want to continue?

[O] Oui  [T] Oui pour tout  [N] Non  [U] Non pour tout  [S] Suspendre  [?] Aide (la valeur par défaut est « N ») : o


StatusCode        : 200
StatusDescription : OK
Content           : <h1>Bienvenue sur mon application Python conteneurisée sur GKE !</h1>
RawContent        : HTTP/1.1 200 OK
                    Connection: close
                    Content-Length: 70
                    Content-Type: text/html; charset=utf-8
                    Date: Mon, 15 Dec 2025 10:39:28 GMT
                    Server: Werkzeug/3.1.4 Python/3.9.25

                    <h1>Bienvenue sur mon appli...
Forms             : {}
Headers           : {[Connection, close], [Content-Length, 70], [Content-Type, text/html; charset=utf-8], [Date, Mon,
                    15 Dec 2025 10:39:28 GMT]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 70
```

6. CI/CD Pipeline