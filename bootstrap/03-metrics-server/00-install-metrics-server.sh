#!/bin/bash

# Add Helm repository
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ --force-update && helm repo update

# Install (--kubelet-insecure-tls required for development/lab environments)
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls}

# Wait for ready
echo "Waiting for Metrics Server to be ready..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metrics-server -n kube-system --timeout=90s