# Azure Kubernetes Terraform Environment

---

## 📖 Overview

This directory contains **Terraform configuration** for provisioning a Kubernetes environment on Azure. The setup automates the creation of an Azure Resource Group and an AKS (Azure Kubernetes Service) cluster, providing outputs for easy integration and management.

- **main.tf**: Defines the Azure provider, resource group, and AKS cluster resources.
- **variables.tf**: Declares configurable variables such as region and resource tags.
- **outputs.tf**: Exposes key outputs like resource group and cluster names.
- **terraform.tfvars**: Used to set variable values for a specific environment.

---

## 📁 Folder Structure

```
model/
  main.tf            # Main Terraform configuration (provider, resources)
  variables.tf       # Input variables and their defaults
  outputs.tf         # Output values after apply
  terraform.tfvars   # Environment-specific variable values
env/
  dev.tfvars.example # Example: template for your dev.tfvars file
  dev.tfvars         # User-specific variable values (should not be checked in)
  # Additional environment configurations can be added here
```

> 📌 **Note:** Use `dev.tfvars.example` as a template to create your own `dev.tfvars` file. Never check in your `dev.tfvars` as it may contain sensitive or environment-specific data.

---

## 🚀 Provisioning Kubernetes on Azure

Follow these steps to deploy the infrastructure:

1. **Authenticate with Azure**
   > 📌 **Tip:** Make sure you are logged in to your Azure account.
```sh
az login
```

2. **Initialize Terraform**
   > This command downloads the required providers and sets up the working directory.
```sh
cd model
terraform init
```

3. **Plan the Deployment**
   > Review the changes Terraform will make. Use the appropriate variable file for your environment.
```sh
terraform plan -var-file="../env/dev.tfvars"
```

4. **Apply the Deployment**
   > Provision the resources in Azure.
```sh
terraform apply -var-file="../env/dev.tfvars"
```

5. **Configure kubectl Access to AKS Cluster**
   > After deployment, configure `kubectl` to access your AKS cluster. If you already have a `.kube/config` file, rename or back it up before running the following command to avoid overwriting your existing configuration.
```sh
# (Optional) Backup existing kubeconfig
mv ~/.kube/config ~/.kube/config.backup

az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)
```

6. **Destroy the Deployment**
   > Remove all resources created by this configuration.
```sh
terraform destroy -var-file="../env/dev.tfvars"
```

---

## ⚙️ Configuration Files Explained

| File                  | Purpose                                                                                   |
|-----------------------|-------------------------------------------------------------------------------------------|
| `main.tf`             | Main configuration: sets up provider, resource group, and AKS cluster.                    |
| `variables.tf`        | Declares input variables (e.g., location, tags) and their default values.                 |
| `outputs.tf`          | Defines outputs such as resource group and cluster names for use after deployment.         |
| `terraform.tfvars`    | Used to set or override variable values for a specific environment.                       |
| `env/dev.tfvars`      | User-specific variable values for the dev environment. Should not be checked in.           |
| `env/dev.tfvars.example` | Example/template for creating your own `dev.tfvars` file.                            |

### 🔎 Difference between `dev.tfvars`, `terraform.tfvars`, and `variables.tf`

- **variables.tf**: Declares all possible input variables and their default values for the module or environment.
- **terraform.tfvars**: Provides default values for variables, typically for a specific environment. Automatically loaded by Terraform if present.
- **dev.tfvars**: User-specific variable overrides for the development environment. Should be created from `dev.tfvars.example` and never checked in to version control. Passed explicitly with `-var-file`.

---

## 🛠️ Troubleshooting

- **Provider or authentication errors**
  > Ensure you are logged in to Azure and have the correct subscription set.
```sh
az login
az account set --subscription "<your-subscription-id>"
```

- **Missing or invalid variable values**
  > Check that all required variables are set in `terraform.tfvars` or passed via `-var-file`.

- **Resource conflicts or quota issues**
  > Review Azure portal for existing resources or quota limits in your subscription.

- **General troubleshooting**
  > Use Terraform logs for more details:
```sh
export TF_LOG=DEBUG
terraform apply -var-file="../env/dev.tfvars"
```

---

## 📚 References

- [Terraform Documentation](https://www.terraform.io/docs/)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)

---
