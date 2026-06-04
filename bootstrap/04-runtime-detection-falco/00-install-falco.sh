#!/bin/bash

# Add the Falco Helm repository
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco with eBPF driver and gRPC output
helm install falco falcosecurity/falco \
  --namespace falco-system \
  --create-namespace \
  -f falco-values.yaml

# Wait for the Falco DaemonSet to be ready
kubectl rollout status daemonset/falco -n falco-system
# Test if it´s running
kubectl logs -n falco-system daemonset/falco | head -20

