# AKS Infrastructure (For Development and Testing))

---

## 📖 Overview

This repository provides a complete, modular infrastructure as code solution for deploying multiple applications to Kubernetes on Azure for development and testing purposes. 
The stack leverages **Terraform** for infrastructure provisioning, **Helm/Helmfile** for Kubernetes application deployment.

### Applications

- **Python REST API**: A minimal Flask application exposing a `/hello` endpoint, containerized for easy deployment, test and as an example workload.

---

## 🗂️ Repository Structure

| Directory/File                | Purpose                                                                 |
|-------------------------------|-------------------------------------------------------------------------|
| `apps/python-rest-api/`       | Source code and Dockerfile for the sample Python REST API application   |
| `devops/terraform/`           | Terraform configuration for Azure infrastructure and AKS cluster        |
| `devops/helm/`                | Helm chart and Helmfile for deploying the API to Kubernetes             |

---

## 🚀 Quick Start

### 1. Provision Azure Infrastructure with Terraform

> 📌 **See:** [`devops/terraform/README.md`](devops/terraform/README.md) for full details and troubleshooting.

- Authenticate with Azure:
  ```sh
  az login
  ```
- Initialize and apply Terraform (from the `model/` directory):
  ```sh
  cd devops/terraform/model
  terraform init
  terraform apply -var-file="../env/dev.tfvars"
  ```
- Configure `kubectl` access to your new AKS cluster:
  ```sh
  az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)
  ```

### 2. Build and Publish the Python REST API Docker Image (Optional)

> 📌 **See:** [`apps/python-rest-api/README.md`](apps/python-rest-api/README.md) for local development, Docker build, and publishing instructions.

- Build the Docker image:
  ```sh
  docker build -t python-rest-api ./apps/python-rest-api
  ```
- (Optional) Push to Docker Hub:
  ```sh
  docker tag python-rest-api <your-dockerhub-username>/python-rest-api:latest
  docker push <your-dockerhub-username>/python-rest-api:latest
  ```

### 3. Deploy to Kubernetes with Helm or Helmfile

> 📌 **See:** [`devops/helm/README.md`](devops/helm/README.md) for full Helm/Helmfile usage and customization.

- Deploy using Helmfile (recommended):
  ```sh
  cd devops/helm
  helmfile sync
  ```
- Or deploy using Helm directly:
  ```sh
  helm install <release_name> ./python-rest-api
  ```

---

## 🌐 DNS labels (FQDNs) for public IPs

When using LoadBalancer services in Kubernetes, Azure assigns a public IP **without** a DNS label. 

To create a DNS label for your public IP, you can use the following **Terraform** configuration:

```hcl
resource "azurerm_public_ip" "example" {
  name                = "example-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "example"
}
```

And then reference this public IP in your Helm service definition:
```yaml
service:
  loadBalancerIP: azurerm_public_ip.example.ip_address
```

Or you can configure the DNS label on the **Helm chart** by adding the following to your `values.yaml`:

```yaml
service:
  annotations:
    service.beta.kubernetes.io/azure-dns-label-name: "example" 
```

Azure will then create a DNS label for the public IP, allowing you to access your service via `example.<region>.cloudapp.azure.com`.

- **Note 01**: This only works **at the time the public IP is created**. 
- **Note 02**: The DNS label must be unique across all public IPs in the Azure region. Suffix your label with a unique identifier if necessary (E.g.: `{{.Release.Name}}`).
- **Note 03**: There is no native command on Helm, kubectl, or Azure CLI to get the FQDN of a public IP created by a Helm chart. You can use the (./devops/scripts/Get-AksServiceFqdn.ps1) script to retrieve the FQDN of a service created by a Helm chart.

If the IP already exists, and you do not want to recreate the service, you’ll need to update it manually using az network public-ip update:

```sh
az network public-ip update --name <public_ip_name> --resource-group <resource_group_name> --set dnsSettings.domainNameLabel=<new_label>
```

### ✅ Best Practice: Use Terraform for Public IP + DNS, Helm for App Deployment

#### Terraform:

- Create the public IP with a DNS label 
- Optionally create a static IP for reuse
- Pass the IP to your Helm chart via values

#### Helm:

- Deploy the service or ingress controller
- Reference the static IP via loadBalancerIP
- Use annotations if you want Azure to create the IP (but lose control over DNS)

**Note:** This project is requesting the FQDN for the public IPs created by the Helm chart (./devops/helm/python-rest-api/templates/service.yaml and ./devops/helm/python-rest-api/values.yaml), since we are expecting to do not know the Services that will be created in advance.
In a production environment, you would typically create the public IPs with Terraform and then pass them to your Helm chart as values.

Here is a table illustrating the differences between using Terraform and Helm for public IP and DNS management:

| Approach                | Control | Flexibility | Best For          |
|-------------------------|---------|-------------|-------------------|
| Helm annotations        | Low     | High        | Dev/test apps      |
| Terraform public IPs    | High    | Medium      | Production apps    |
| Azure DNS zone          | Very High| High       | Custom domains     |

## 🧩 Components

### Python REST API
- Minimal Flask API exposing `/hello` endpoint.
- Containerized for portability and easy deployment.
- See [`apps/python-rest-api/README.md`](apps/python-rest-api/README.md) for details.

### Terraform Infrastructure
- Provisions Azure Resource Group and AKS cluster.
- Modular, environment-based configuration.
- See [`devops/terraform/README.md`](devops/terraform/README.md) for usage, variables, and troubleshooting.

### Helm & Helmfile Deployment
- Helm chart for the Python REST API with customizable values.
- Helmfile for declarative, multi-environment release management.
- See [`devops/helm/README.md`](devops/helm/README.md) for deployment and customization.

---

## 🛠️ Troubleshooting & Useful Commands

- **Terraform:** See troubleshooting in [`devops/terraform/README.md`](devops/terraform/README.md)
- **Helm/Helmfile:** See troubleshooting in [`devops/helm/README.md`](devops/helm/README.md)
- **Python REST API:** See [`apps/python-rest-api/README.md`](apps/python-rest-api/README.md)

### Usefull commands

#### Helm

- `helm list` # List releases
- `helm list -a` # List all releases, including those that are deleted or failed
- `helm install <release_name> <chart> [flags]` # Install a chart
- `helm uninstall <release_name>` # Uninstall a release
- `helm upgrade <release_name> <chart> [flags]` # Upgrade a release
- `helm rollback <release_name> <revision>` # Rollback a release to a previous revision. The revision number can be found with `helm history <release_name>`
- `helm history <release_name>` # List the history of a release
- `helm create <chart_name>` # Create a new chart
- `helm repo add <repo_name> <repo_url>` # Add a Helm chart repository
- `helm repo list` # List all added Helm chart repositories
- `helm repo update` # Update information of available charts
- `helm search repo <chart>` # Search for a chart in repositories
- `helm search hub <keyword>` # Search for charts on Artifact Hub
- `helm search hub <keyword> --max-col-width="0"` # Search Artifact Hub with unlimited column width for better readability
- `helm search <repo> <keyword> [--max-col-width="0"]` # Search for a chart in a specific repository with optional column width
- `helm get all <release_name>` # Get all information about a release
- `helm template <chart>` # Render chart templates locally
- `helm lint <chart>` # Lint a chart to check for issues
- `helm show readme <chart> [--version <version>]` # Show the README for a chart, optionally for a specific version

##### HelmFile

- `helmfile sync` # Synchronize the state of releases defined in the Helmfile with the cluster
- `helmfile apply` # Apply the Helmfile configuration, installing or upgrading releases as defined

#### kubectl

- `kubectl get services` # List all services in the current namespace with among others, the IP address and port
- `kubectl get pods` # List all pods in the current namespace
- `kubectl get nodes` # List all nodes in the cluster
- `kubectl describe pod <pod_name>` # Show details of a specific pod
- `kubectl logs <pod_name>` # Print the logs for a container in a pod
- `kubectl apply -f <file.yaml>` # Apply a configuration to a resource by file
- `kubectl delete -f <file.yaml>` # Delete resources by file
- `kubectl exec -it <pod_name> -- /bin/sh` # Execute a command inside a pod
- `kubectl port-forward <pod_name> <local_port>:<remote_port>` # Forward one or more local ports to a pod

##### MicroK8s

- `microk8s dashboard-proxy` # Start the dashboard proxy
- `microk8s dashboard` # Open the MicroK8s dashboard in your browser
- `microk8s status` # Show the status of MicroK8s and enabled add-ons
- `microk8s enable <addon>` # Enable an add-on (e.g., dns, dashboard, ingress)
- `microk8s disable <addon>` # Disable an add-on
- `microk8s start` # Start MicroK8s
- `microk8s stop` # Stop MicroK8s
- `microk8s restart` # Restart MicroK8s
- `microk8s kubectl <command>` # Run kubectl commands directly with MicroK8s context
- `microk8s config` # Show kubeconfig for MicroK8s
- `microk8s reset` # Reset MicroK8s to a fresh state
- `microk8s upgrade` # Upgrade MicroK8s to the latest version
- `microk8s inspect` # Run a diagnostics of the MicroK8s installation

##### Multipass

- `multipass launch` # Launch a new instance
- `multipass list` # List all instances and their IP addresses
- `multipass shell <instance>` # Open a shell on the specified instance
- `multipass exec <instance> -- <command>` # Run a command on the specified instance
- `multipass stop <instance>` # Stop an instance
- `multipass start <instance>` # Start an instance
- `multipass restart <instance>` # Restart an instance
- `multipass delete <instance>` # Delete an instance
- `multipass purge` # Delete all deleted instances and free up disk space
- `multipass info <instance>` # Get detailed information about an instance
- `multipass mount <host_path> <instance>:<mount_path>` # Mount a local directory into an instance
- `multipass unmount <instance>:<mount_path>` # Unmount a directory from an instance

---

## 📚 References & Further Reading

- [Terraform Documentation](https://www.terraform.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Helmfile Documentation](https://github.com/roboll/helmfile)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---