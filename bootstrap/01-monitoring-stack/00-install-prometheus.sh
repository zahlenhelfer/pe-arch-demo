#!/bin/bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update && helm repo update

# Install kube-prometheus-stack
helm install grafana-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values grafana-stack-values.yaml \
  --wait
