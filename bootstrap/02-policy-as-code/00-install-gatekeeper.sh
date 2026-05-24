#!/bin/bash

# Apply Gatekeeper manifests
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts --force-update && helm repo update

# Install Gatekeeper via Helm
helm install gatekeeper/gatekeeper \
  --name-template=gatekeeper \
  --namespace gatekeeper-system \
  --create-namespace \
  -f gatekeeper-values.yaml \
  --wait

# Wait for Gatekeeper to be ready
kubectl wait --for=condition=Ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=90s
