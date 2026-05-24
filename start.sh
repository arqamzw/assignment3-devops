#!/bin/bash

cd ~/assignment3

echo "Starting Minikube..."
minikube start --driver=docker --memory=2048 --cpus=2

echo "Waiting for Minikube to be ready..."
kubectl wait --for=condition=Ready node/minikube --timeout=120s

echo "Creating namespace..."
kubectl apply -f k8s/namespace.yml

echo "Waiting for namespace to be ready..."
sleep 5

echo "Applying secrets and configmaps..."
kubectl apply -f k8s/mysql-secret.yml
kubectl apply -f k8s/flask-configmap.yml

echo "Applying storage..."
kubectl apply -f k8s/mysql-pv.yml
kubectl apply -f k8s/mysql-pvc.yml

echo "Deploying MySQL..."
kubectl apply -f k8s/mysql-deployment.yml
kubectl apply -f k8s/mysql-service.yml

echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=Ready pod -l app=mysql -n assignment3 --timeout=180s

echo "Deploying Flask..."
kubectl apply -f k8s/flask-deployment.yml
kubectl apply -f k8s/flask-service.yml

echo "Deploying Nginx..."
kubectl apply -f k8s/nginx-configmap.yml
kubectl apply -f k8s/nginx-deployment.yml
kubectl apply -f k8s/nginx-service.yml

echo "Waiting for all pods to be ready..."
kubectl wait --for=condition=Ready pod --all -n assignment3 --timeout=180s

echo ""
echo "=== Deployment Status ==="
kubectl get all -n assignment3

echo ""
echo "=== Access URL ==="
minikube service nginx -n assignment3 --url
