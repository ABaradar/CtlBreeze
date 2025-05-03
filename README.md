# CtlBreeze

**CtlBreeze** is a declarative Kubernetes deployment designed for minimal maintenance and airgap environments. It leverages [k0s](https://k0sproject.io/) and [k0sctl](https://github.com/k0sproject/k0sctl) for cluster provisioning and upgrades, ensuring an easy and automated setup.

---

## Key Features

- **Declarative and Automated**:
  The cluster is defined in a YAML configuration file, making it easy to apply and manage.

- **Airgap Support**:
  Designed for environments with limited or no internet access by preloading images and dependencies.

- **Minimal Maintenance**:
  Upgrading Kubernetes is as simple as updating the version in the configuration file and reapplying it.

- **Secure and Resilient**:
  Implements encryption, high availability, and load balancing for a reliable setup.

---

## Prerequisites

### Passwordless SSH and Sudo

To ensure seamless automation, SSH access must be set up without requiring a password for authentication. Additionally, sudo commands should not prompt for a password.

### SSH Private Key in CI/CD

The CI/CD pipeline requires an SSH private key to access nodes. This key must be stored securely in GitLab CI/CD as a variable named `SSH_PRIVATE_KEY`. To generate the base64-encoded version, run:

```bash
cat id_rsa | base64 -w0
```

### CI/CD Variable for kubeconfig Encryption

In order to enhance security, the generated `kubeconfig` file is encrypted before being stored as an artifact. The encryption uses OpenSSL with AES-256-CBC. For this to work, you need to set a new CI/CD variable called `KUBECONFIG_PASSWORD`. This variable holds the password used to encrypt the `kubeconfig` file. Ensure that the variable is kept secret and only available in your CI/CD environment.

### Decrypting the Encrypted kubeconfig

To decrypt the `kubeconfig.yaml.enc` file and retrieve the original `kubeconfig.yaml`, run the following command: (replace \<PASSWORD\> accordingly)

```bash
openssl enc -d -aes-256-cbc -in kubeconfig.yaml.enc -out kubeconfig.yaml -k "<PASSWORD>"
```

### (Optional Storage Configuration)
To enable communication between your k0s cluster and a Ceph storage backend, ensure the following:

* Kernel Modules: Load the rbd and nbd kernel modules on each k0s worker node:
```bash
sudo modprobe rbd
sudo modprobe nbd
echo -e "rbd\nnbd" | sudo tee /etc/modules-load.d/ceph.conf # Persist Across Reboots
```

* If MicroCeph is installed on the same worker nodes via Snap, it typically manages the necessary kernel modules automatically through the kernel-module-load interface.

---

# TLDR

*  Fill in the placeholders in your cluster‑definition and .gitlab‑ci, and you’re ready to deploy:

| Placeholder               | Description                                                 |
| ------------------------- | ----------------------------------------------------------- |
| `<master-ip>…<worker-ip>` | IP addresses of all control‑plane and worker nodes          |
| `<ssh-user>`              | Linux user for k0sctl SSH connections                       |
| `<local-repo>`            | Base URL or path for mirror of GitHub artifacts & OCI images|
| `<keepalive-vip>`         | Virtual IP for external kubectl/API‑server access           |
| Optional parameters       |                                                             |
| `<mon-ip>…<mon-ip>`       | IPs of Ceph monitor nodes                                   |
| `<mon-port>…<mon-port>`   | Corresponding ports for each Ceph monitor (default: `6789`) |
| `<cluster-id>`            | Ceph cluster identifier                                     |
| `<auth-token>`            | Ceph user’s authentication key                              |

# Deployment Considerations

## High Availability

- **Keepalived** is used to provide a virtual IP address for the control plane, ensuring redundancy.
- Master nodes should be **rebooted after the initial installation** to ensure Keepalived operates correctly.

## Networking

- **Calico with WireGuard** is used to encrypt pod-to-pod communication, enhancing cluster security.
- **Node Local Load Balancing (NLLB)** with Envoy Proxy is enabled to distribute traffic efficiently within the cluster (workers to masters).
- **Control Plane Load Balancing (CPLB)** is handled using Keepalived, ensuring API server requests (from outside the cluster) are balanced among master nodes.

## Binary and Image Bundle Details

- The binary and image bundle are downloaded using the version variable, ensuring the correct version is fetched automatically.
- The download utilizes a Nexus mirror (configured as a raw repository) to connect to GitHub, offering a reliable and controlled source.
- The **k0sctl binary** will always be the latest available for the **amd64** architecture.
- Unused components (e.g., Windows worker nodes, autopilot) are disabled via specific disable component flags (such as `--disable-components=autopilot`, and `--disable-components=windows-node`).

## Image Pull Policy

- The image pull policy is set to `Never`, meaning all required container images must be preloaded.
- This prevents unexpected external dependencies in airgap environments.

## CoreDNS Configuration Note

- Changing the CoreDNS config map using k0s is not supported yet, as discussed in [Issue 4459](https://github.com/k0sproject/k0s/issues/4459) and [Issue 4021](https://github.com/k0sproject/k0s/issues/4021).
- Consequently, CoreDNS is disabled by default and its configuration is managed using a manifest deployer (for example, to spoof domains (included in sample) or disable IPv6 loops) hence the flag `--disable-components=coredns`.

## Telemetry

- **Telemetry and anonymous usage data reporting** are disabled for privacy reasons.

---

# CI/CD Pipeline & Artifacts

## k0sctl Execution

- The `k0sctl apply` command is used to deploy or update the cluster.
- The command output is stored for debugging and auditing.

## Artifacts Storage

- The `kubeconfig` file and `k0sctl` execution logs are stored as GitLab artifacts.
- These artifacts remain available for **3 days** to facilitate debugging and accessing the cluster.

## Upgrading Kubernetes

- Kubernetes can be upgraded by changing the version in the cluster configuration YAML file.
- Running `k0sctl apply` with the updated configuration will automatically upgrade the cluster.

## Optional Storage: MicroCeph & Ceph CSI

This section describes how to set up a lightweight Ceph cluster using MicroCeph, why you might choose it, and how to expose that storage to Kubernetes via the Ceph CSI driver installed through k0s’ Helm extensions.

### 1. MicroCeph Overview & Benefits

MicroCeph is a snap‑packaged, minimal‑ops distribution of Ceph that makes it trivial to bootstrap a production‑grade SDS (software‑defined storage) cluster on as few as three nodes or even a single host for testing.

* **Lightweight & Fast to Deploy:** shipped as a single snap; a cluster can be bootstrapped in minutes with one command.
* **Secure & Sandbox‑ed:** runs fully containerized and sandboxed from the host OS, reducing attack surface.
* **Scalable & Resilient:** supports block, file, and object storage; scales from edge use‑cases to multi‑petabyte datacenters.
* **Built‑in HA:** with three nodes, OSD redundancy and automatic failover provide high availability without extra orchestration ([Canonical](https://canonical-microceph.readthedocs-hosted.com/en/squid-stable/how-to/multi-node/)).

### 2. Initializing & Clustering MicroCeph

* Install the snap on each intended Ceph node:

    ```bash
    sudo snap install microceph --channel=latest/stable
    sudo snap refresh --hold microceph
    ```

* Bootstrap a new cluster (on the first node):

    ```bash
    sudo microceph cluster bootstrap
    ```

    This generates a Ceph mon, mgr, and OSD on that host.

* Add additional nodes by running this command on first node and retrieving the corresponding token:

    ```bash
    $ sudo microceph cluster add worker-2
    eyJuYW1lIjoibm9kZS0yIiwic2VjcmV0IjoiYmRjMzZlOWJmNmIzNzhiYzMwY2ZjOWVmMzRjNDM5YzNlZTMzMTlmZDIyZjkxNmJhMTI1MzVkZmZiMjA2MTdhNCIsImZpbmdlcnByaW50IjoiMmU0MmEzYjEwYTg1MDcwYTQ1MDcyODQxZjAyNWY5NGE0OTc4NWU5MGViMzZmZGY0ZDRmODhhOGQyYjQ0MmUyMyIsImpvaW5fYWRkcmVzc2VzIjpbIjEwLjI0Ni4xMTQuMTE6NzQ0MyJdfQ==
    ```

* Use the generated token to join nodes (from the corresponding node)
    ```bash
    $ sudo microceph cluster join eyJuYW1lIjoibm9kZS0yIiwic2VjcmV0IjoiYmRjMzZlOWJmNmIzNzhiYzMwY2ZjOWVmMzRjNDM5YzNlZTMzMTlmZDIyZjkxNmJhMTI1MzVkZmZiMjA2MTdhNCIsImZpbmdlcnByaW50IjoiMmU0MmEzYjEwYTg1MDcwYTQ1MDcyODQxZjAyNWY5NGE0OTc4NWU5MGViMzZmZGY0ZDRmODhhOGQyYjQ0MmUyMyIsImpvaW5fYWRkcmVzc2VzIjpbIjEwLjI0Ni4xMTQuMTE6NzQ0MyJdfQ==
    ```

* Add storage devices on each node:

    ```bash
    $ sudo microceph disk add --all-available --wipe
    # or
    $ sudo microceph disk add /dev/vdb --wipe
    ```

    Ensure ≥12 GiB free on the root disk.

* Verify cluster health:

    ```bash
    sudo microceph status
    sudo ceph status
    ```

    You should see all MONs, MGRs, and OSDs reporting `HEALTH_OK`. ([microk8s.io](https://microk8s.io/))

### 3. Create pool and credential to consume ceph in kubernetes

* Create a Pool
```bash
ceph osd pool create kubernetes
```

* A newly created pool must be initialized prior to use. Use the rbd tool to initialize the pool:
```bash
rbd pool init kubernetes
```

* Setup Ceph Client Authentication
```bash
$ ceph auth get-or-create client.kubernetes mon 'profile rbd' osd 'profile rbd pool=kubernetes' mgr 'profile rbd pool=kubernetes'
[client.kubernetes]
    key = AQDIhxRoox5uNBAAUljjJ3S9LVN27i63Paa0Iw==
```

* Retrieve Ceph monitor addresses & cluster id
```bash
$ ceph mon dump
<...>
fsid 9d8b0c3b-00c6-4fdb-8ac7-d7ae0dfda41c
<...>
0: [v2:192.168.1.1:3300/0,v1:192.168.1.1:6789/0] mon.worker-1
1: [v2:192.168.1.2:3300/0,v1:192.168.1.2:6789/0] mon.worker-2
2: [v2:192.168.1.3:3300/0,v1:192.168.1.3:6789/0] mon.worker-3
```

### 4. Ceph CSI via k0s Helm Extensions

To consume your MicroCeph block storage in Kubernetes, deploy the RBD CSI driver using k0s’ built‑in Helm extension mechanism. Below is a minimal snippet; adjust monitors, clusterID, secrets, and image repositories to match your environment.

```yaml
extensions:
  helm:
    concurrencyLevel: 1
    repositories:
      - name: ceph-csi
        url: https://ceph.github.io/csi-charts
    charts:
      - name: ceph-csi-rbd
        chartname: ceph-csi/ceph-csi-rbd
        version: "3.14.0"
        timeout: 5m
        order: 1
        values: |
          rbac:
            create: true
          serviceAccounts:
            nodeplugin:
              create: true
            provisioner:
              create: true
          csiConfig:
            - clusterID: "9d8b0c3b-00c6-4fdb-8ac7-d7ae0dfda41c"
              monitors:
                - "192.168.1.1:6789"
                - "192.168.1.2:6789"
                - "192.168.1.3:6789"
          nodeplugin:
            registrar:
              image:
                repository: nexus.local/sig-storage/csi-node-driver-registrar
            plugin:
              image:
                repository: nexus.local/cephcsi/cephcsi
          provisioner:
            replicaCount: 3
            strategy:
              type: RollingUpdate
              rollingUpdate:
                maxUnavailable: 50%
            provisioner:
              image:
                repository: nexus.local/sig-storage/csi-provisioner
            attacher:
              enabled: true
              image:
                repository: nexus.local/sig-storage/csi-attacher
            resizer:
              enabled: true
              image:
                repository: nexus.local/sig-storage/csi-resizer
            snapshotter:
              image:
                repository: nexus.local/sig-storage/csi-snapshotter
          storageClass:
            create: true
            name: csi-rbd-sc
            clusterID: 9d8b0c3b-00c6-4fdb-8ac7-d7ae0dfda41c
            pool: kubernetes
            provisionerSecret: csi-rbd-secret
            controllerExpandSecret: csi-rbd-secret
            nodeStageSecret: csi-rbd-secret
            fstype: ext4
            reclaimPolicy: Delete
            allowVolumeExpansion: true
          secret:
            create: true
            name: csi-rbd-secret
            userID: kubernetes
            userKey: AQDIhxRoox5uNBAAUljjJ3S9LVN27i63Paa0Iw==
          kubeletDir: /var/lib/k0s/kubelet
        namespace: ceph-csi-rbd
```
This uses the `ceph-csi‑rbd` chart from the official [Ceph CSI Charts repo](https://github.com/ceph/ceph-csi/tree/devel/charts/ceph-csi-rbd).

All RBAC, service accounts, sidecars, and StorageClass definitions are handled via the `values` block .

Once k0s applies this extension, you’ll have a new namespace `ceph-csi-rbd` and `csi-rbd-sc` StorageClass. PVCs referencing it will dynamically provision RBD volumes on your MicroCeph cluster.

You can of course adapt these values to enable CephFS CSI (`ceph-csi/ceph-csi-cephfs` chart), or tweak pools, secrets, and scaling parameters as needed.

## Optional repository manager: Sonatype Nexus Repository

- [Nexus Setup & Terraform](nexus/README.md)