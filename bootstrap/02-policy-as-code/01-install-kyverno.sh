#!/bin/bash
helm repo add kyverno https://kyverno.github.io/kyverno/ --force-update && helm repo update

# Install Kyverno via Helm
helm install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace \
  -f kyverno-values.yaml

# Wait for Kyverno to be ready
kubectl wait --for=condition=Ready pod -l app=kyverno -n kyverno --timeout=90s
