#!/bin/bash

set -e

echo "Building JAR..."
./mvnw clean package -DskipTests

echo "Building Docker image..."
docker build -t hello-k8s-spring:v1 .

echo "Loading image into Kind..."
kind load docker-image hello-k8s-spring:v1 --name desktop

echo "Applying Kubernetes resources..."
kubectl apply -f k8s-deployment.yaml

echo "Restarting deployment..."
kubectl rollout restart deployment/spring-api-deployment

echo "✅ Done! Check status: kubectl get pods"

