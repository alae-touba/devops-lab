
# DevOps Lab: Spring Boot on Kind (WSL2)

This repository contains a local Kubernetes development environment for a Spring Boot application. It runs on a Kind cluster inside WSL2, accessible from a Windows browser via a custom domain.

## Overview

* **Stack:** Java 21 (Spring Boot), Docker, Kubernetes (Kind).
* **Environment:** Windows 11 Host  WSL2 (Ubuntu).
* **Networking:** NGINX Ingress Controller with local port mapping.

## Prerequisites

### Windows

1. **Docker Desktop:** Installed with "Use the WSL 2 based engine" enabled.
2. **WSL Integration:** Enabled for your specific distro (Settings > Resources > WSL Integration).
3. **Kubernetes:** Ensure the built-in Kubernetes in Docker Desktop is **disabled** to avoid conflicts.

### WSL2 (Linux Terminal)

Ensure the following tools are installed in your Ubuntu environment:

* `kubectl`
* `kind`
* `docker` (CLI)

## 1. Cluster Setup

Standard Kind clusters don't expose ports to the host machine by default. We use a custom configuration to map port 80 from the container to the host.

### Create Config

Create a file named `kind-config.yaml` in the root directory:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP

```

### Initialize Cluster

Run this command to create the cluster with the port mappings:

```bash
kind create cluster --name desktop --config kind-config.yaml

```

### Install Ingress Controller

We use NGINX to route external traffic to our services.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

```

## 2. Networking (Hosts File)

To access the application via a custom domain instead of `localhost`, you need to modify the Windows hosts file.

1. Open **Notepad** as Administrator.
2. Edit `C:\Windows\System32\drivers\etc\hosts`.
3. Add the following line:
```text
127.0.0.1  my-app.local

```



## 3. Quick Start (Automated)

Once your cluster is set up, use the automation script for a one-command deployment:

```bash
./build-and-deploy.sh
```

This script will:
1. Build the JAR with Maven
2. Create the Docker image (`hello-k8s-spring:v1`)
3. Load the image into the Kind cluster
4. Apply all Kubernetes resources (ConfigMap, Deployment, Service, Ingress)
5. Restart the deployment to pick up changes

## 4. Development Workflow

### Option A: Automated (Recommended)

```bash
./build-and-deploy.sh
```

### Option B: Manual Steps

Since Kind runs in a Docker container, it cannot see images built locally unless you explicitly load them.

**1. Package the Application**

```bash
./mvnw clean package -DskipTests
```

**2. Build Docker Image**

```bash
docker build -t hello-k8s-spring:v1 .
```

**3. Load Image into Cluster**

```bash
kind load docker-image hello-k8s-spring:v1 --name desktop
```

**4. Deploy to Kubernetes**

```bash
kubectl apply -f k8s-deployment.yaml
```

**5. Restart Deployment (if updating existing deployment)**

```bash
kubectl rollout restart deployment/spring-api-deployment
```


## 5. Access & Verification

Once deployed, the application should be accessible from your Windows browser.

*   **Application Root:** `http://my-app.local/`  
*   **Test the api:** `http://my-app.local/hello`
*   **Health Check:** `http://my-app.local/actuator/health`

### Troubleshooting Commands

If the site is unreachable, check the status of the ingress controller and pods:

```bash
# Check if pods are running
kubectl get pods

# Check if ingress has an address (should be localhost/127.0.0.1)
kubectl get ingress

# View application logs
kubectl logs -l app=hello-k8s-spring -f

```