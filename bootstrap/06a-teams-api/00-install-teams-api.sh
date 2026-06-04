#!/bin/bash
echo "Install Teams API on the Cluster..."
kubectl apply -f teams-api-deployment.yaml

echo "Waiting for Teams API to be ready..."
kubectl rollout status deployment/teams-api --namespace engineering-platform --timeout=60s

echo "Teams API has been successfully deployed and is ready to use."
