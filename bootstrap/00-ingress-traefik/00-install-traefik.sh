#!/bin/bash

# Add the official Traefik Helm repository and refresh the local cache
helm repo add traefik https://helm.traefik.io/traefik --force-update && helm repo update

# Install Traefik into its own namespace using the custom values file
helm install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --values traefik-values.yaml
