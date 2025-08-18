# AKS Infrastructure Template

This repository provides infrastructure as code for deploying a sample Python REST API application to Kubernetes using Helm and Helmfile.

## What this project does

- **Python REST API**: Implements a simple REST API using Flask, exposing a `/hello` endpoint that returns a JSON response `{ "data": "Hello World" }` on GET requests.
- **Dockerized Application**: The application is containerized using a Dockerfile based on Python 3.8, installing dependencies from `requirements.txt` and running the Flask app on port 9001.
- **Helm Chart**: The `python-rest-api` Helm chart allows customizable deployment options, including replica count, image repository, service type (default NodePort on 9001), ingress, resources, and more via `values.yaml`.
- **Helmfile Management**: The `helmfile.yaml` file manages the deployment of the Helm chart, making it easy to define, sync, and apply release configurations.
- **Kubernetes Ready**: The setup supports local development with MicroK8s and Multipass, as well as deployment to Azure Kubernetes Service (AKS) or any other Kubernetes cluster.

# Use full commands

## Helm

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

### HelmFile

- `helmfile sync` # Synchronize the state of releases defined in the Helmfile with the cluster`
- `helmfile apply` # Apply the Helmfile configuration, installing or upgrading releases as defined

## kubectl

- `kubectl get services` # List all services in the current namespace with among others, the IP address and port
- `kubectl get pods` # List all pods in the current namespace
- `kubectl get nodes` # List all nodes in the cluster
- `kubectl describe pod <pod_name>` # Show details of a specific pod
- `kubectl logs <pod_name>` # Print the logs for a container in a pod
- `kubectl apply -f <file.yaml>` # Apply a configuration to a resource by file
- `kubectl delete -f <file.yaml>` # Delete resources by file
- `kubectl exec -it <pod_name> -- /bin/sh` # Execute a command inside a pod
- `kubectl port-forward <pod_name> <local_port>:<remote_port>` # Forward one or more local ports to a pod

### MicroK8s

- `microk8s dashboard-proxy` # Start the dashboard proxy`
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

### Multipass

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

# Helm Workflow / Architecture

This section describes the architecture and several workflows of using Helm in general

## Helm Debug - Dry-Run

![](./docs/helm_debug_dry_run.png)

This diagram illustrates the Helm debug and dry-run workflow. 
It shows how Helm interacts with the Kubernetes API server to render templates and validate configurations without making any changes to the cluster.
Once its verified, you can proceed with the actual deployment.
The dry-run option can be used with the `helm install` and `helm upgrade` commands to simulate the deployment process. As for example:
```powershell
helm install <release_name> <chart> --dry-run --debug
```


## Troubleshooting

### kubectl or helm commands cannot connect with the microk8s cluster after machine restart

Commonly this issue occours because the ip address of the multipass VM has changed after a restart.
By default, Multipass uses DHCP via Hyper-V’s default virtual switch. That means every time the VM or host reboots, it may get a new IP address. Kubernetes (and tools like MicroK8s) don’t love that.

You can check if the ip of the matches the one of the error message by running the following command:

```powershell
multipass list
```

To fix this issue, you can update the kubeconfig file to point to the new IP address of the MicroK8s VM. 
You can do this by running the following command:

```powershell
microk8s config > $HOME\.kube\config
```

### You cannot access a service via the browser

If you configured the service to be exposed NodePort, you need to make sure you are accessing with the correct IP address and port.

You can find the NodePort by running:
```powershell
kubectl get services
```

You need to use the IP address of the multipass VM, which you can find by running:
```powershell
multipass list
```
### Certificate issues due to VM IP address change (Reset MicroK8s)

1. Enter your Multipass VM:

   ```sh
   multipass shell <vm-name>
   ```

2. Remove MicroK8s completely:

   ```sh
   sudo snap remove microk8s --purge
   ```

3. Delete leftover MicroK8s data and certificates:

   ```sh
   sudo rm -rf /var/snap/microk8s
   rm -rf ~/.kube
   ```

4. (Optional) Clear iptables rules:

   ```sh
   sudo iptables -F
   sudo iptables -t nat -F
   ```

5. Reinstall MicroK8s:

   ```sh
   sudo snap install microk8s --classic
   ```

6. Enable dashboard (if needed):

   ```sh
   microk8s enable dashboard
   ```

# References and More Information
- [Helm Documentation](https://helm.sh/docs/)
- [MicroK8s Documentation](https://microk8s.io/docs/)
- [Multipass Documentation](https://multipass.run/docs)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)

## Additional Credits
This template is inspired by the excelent video [Complete Helm Chart Tutorial: From Beginner to Expert Guide](https://www.youtube.com/watch?v=DQk8HOVlumI&list=PLwP0_p1bqAOWhKGcfDLMw8nIHfkTf0p9E&index=59) by *Rahul Wagh*.