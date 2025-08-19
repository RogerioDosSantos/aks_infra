# Python REST API Helm Chart

---

## 📖 Overview

This directory contains the **Helm chart** for deploying the Python REST API application to Kubernetes. The chart is designed for flexibility and can be customized for different environments using the `values.yaml` file.

- **Chart.yaml** defines the chart metadata (name, version, description).
- **values.yaml** provides default configuration values for the deployment (replica count, image, service type, etc.).
- **helmfile.yaml** manages releases and simplifies multi-environment or multi-release deployments.

---

## 🚀 Deploying to Kubernetes

### Using Helmfile (Recommended)

**Helmfile** allows you to manage multiple Helm releases declaratively. The provided `helmfile.yaml` defines the release for the Python REST API chart.

> 📌 **Note:** Make sure you have [Helmfile](https://github.com/roboll/helmfile) installed.

#### 1. Install or Update the Release
This will install or update the release(s) defined in `helmfile.yaml`:
```bash
helmfile sync
```

#### 2. Uninstall the Release
To uninstall and remove the release(s), edit `helmfile.yaml` and set `installed: false` for the release you want to remove. Then run:
```bash
helmfile sync
```

> 📌 **Tip:** Any changes to releases (install, update, or uninstall) should be made by editing `helmfile.yaml` and then running `helmfile sync` to apply them.

---

### Using Helm

Follow these steps to deploy the Python REST API using Helm:

1. **Add the Helm chart repository (if using a remote repo)**
   > 📌 **Tip:** If deploying from a local directory, you can skip this step.
   ```bash
   helm repo add <repo_name> <repo_url>
   helm repo update
   ```

2. **Install the Helm chart**
   > Replace `<release_name>` with your desired release name. Run this command from the `devops/helm` directory:
   ```bash
   helm install <release_name> ./python-rest-api
   ```

3. **Verify the deployment**
   > Check the status of your release and the created Kubernetes resources:
   ```bash
   helm list
   kubectl get pods
   kubectl get services
   ```

4. **Upgrade the release (if you change values)**
   > Update your deployment with new values:
   ```bash
   helm upgrade <release_name> ./python-rest-api -f ./python-rest-api/values.yaml
   ```

5. **Uninstall the release**
   > Remove the deployment and all associated resources:
   ```bash
   helm uninstall <release_name>
   ```

---


## ⚙️ Customizing Your Deployment

You can override default settings in `values.yaml` to customize your deployment. Common options include:

| Parameter         | Description                                 | Default                |
|-------------------|---------------------------------------------|------------------------|
| `replicaCount`    | Number of pod replicas                      | 1                      |
| `image.repository`| Docker image repository                     | rogersantosmicrosoft/python-rest-api |
| `image.tag`       | Docker image tag                            | latest                 |
| `service.type`    | Kubernetes service type                     | LoadBalancer           |
| `service.port`    | Service port                                | 9001                   |
| `ingress.enabled` | Enable ingress controller                   | false                  |

> 📌 **Tip:** To override values at install/upgrade time, use the `-f` flag with your custom YAML file or `--set` for individual values.

```bash
helm install <release_name> ./python-rest-api -f my-values.yaml
# or
helm install <release_name> ./python-rest-api --set replicaCount=3
```

---

## 🛠️ Troubleshooting

### Helm/Kubernetes Common Issues

- **Release not found or failed:**
  > Check the status and history of your release:
  ```bash
  helm list -a
  helm status <release_name>
  helm history <release_name>
  ```

- **Pods not starting or in CrashLoopBackOff:**
  > Inspect pod logs and events:
  ```bash
  kubectl get pods
  kubectl describe pod <pod_name>
  kubectl logs <pod_name>
  ```

- **Service not reachable:**
  > Ensure the service type and port are correct. For LoadBalancer, check the external IP:
  ```bash
  kubectl get services
  # For NodePort, use the node's IP and the assigned port.
  ```

- **Template rendering errors:**
  > Use Helm's dry-run and debug options to validate templates before deploying:
  ```bash
  helm install <release_name> ./python-rest-api --dry-run --debug
  ```

- **Ingress not working:**
  > Make sure ingress is enabled in `values.yaml` and your cluster has an ingress controller installed.

---

## 📚 References
- [Helm Documentation](https://helm.sh/docs/)
- [Helmfile Documentation](https://github.com/roboll/helmfile)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AKS Infrastructure Template Guide](../README.md)

---
