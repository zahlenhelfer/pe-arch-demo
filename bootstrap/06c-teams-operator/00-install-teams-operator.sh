#!/bin/bash

echo "Installing Teams API Operator"
kubectl apply -f teams-api-operator.yaml

echo "Waiting for Teams API Operator to be ready..."
kubectl rollout status deployment/teams-operator --namespace engineering-platform --timeout=60s

echo "Teams API Operator installation complete."