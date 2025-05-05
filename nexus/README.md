# Nexus Setup & Terraform

This document explains how to configure a Docker‑based Nexus 3 instance with group+mirror repos, retrieve the initial admin password, and deploy the Nexus configuration via Terraform.

## 0. Copy Docker folder to the desired destination

This configuration assumes you have a TLS certificate and key named nexus.crt & nexus.key that you want to use for Nexus. Place them in the `docker/cert` folder.

* Nginx is configured so that if any Docker request hits it, the request will be redirected to the docker‑group repository.

In order to bring up the whole stack:

```bash
sudo docker compose up -d
```

## 1. Group vs. Mirror Repositories

- **Group repository**
  Aggregates multiple hosted or proxy repositories into a single URL endpoint, so clients need only one repository address to access all member repos.
- **Proxy (mirror) repository**
  Caches artifacts on‑demand from a remote registry; you can then add one or more mirror URLs under the “Mirrors” tab to distribute load or provide fail‑over in case of remote repository down time.

## 2. Retrieving the Admin Password

When the Nexus container first starts, it auto‑generates an admin password and writes it to the `admin.password` file inside the data volume .

To read that password:

```bash
docker exec -it nexus cat /nexus-data/admin.password
```

Use admin as the username and the printed string as the password for first login.

## 3. Terraform Deployment

We use the [datadrivers/nexus Terraform provider](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs) to create repos, blobstores, roles, etc.

## 3.1 Provider Configuration

Fill in the placeholders in `terraform/main.tf`:

```terraform
provider "nexus" {
  insecure = true
  url      = "<nexus url>"
  username = "<nexus user>"
  password = "<nexus admin password>"
}
```

## 3.2 Workflow

1.  **Initialize Terraform**
    Prepares the working directory and downloads the Nexus provider plugin.

    ```bash
    cd nexus/terraform
    terraform init
    ```

2.  **Review Plan (optional but recommended)**

    ```bash
    terraform plan
    ```

3.  **Apply Configuration**
    Creates all defined repositories, groups, and permissions in Nexus.

    ```bash
    terraform apply
    ```

That’s it – after the `terraform apply` command completes, your Nexus instance will have the group & mirror repos, blobstores, and any other resources defined in your `.tf` files.

Feel free to adjust naming, ports, or repository formats to match your environment.