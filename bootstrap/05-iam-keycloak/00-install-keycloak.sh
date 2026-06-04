#!/bin/bash
echo "Install Keycloak on the Cluster..."
kubectl apply -f keycloak-deployment.yaml

echo "Waiting for Keycloak to be ready..."
kubectl rollout status deployment/keycloak --namespace keycloak --timeout=60s

echo "Testing Keycloak by fetching health check..."
sleep 3
curl --fail --silent --show-error http://platform-auth.172.18.255.254.sslip.io