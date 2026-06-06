#!/bin/bash
echo "Installing Teams UI"
kubectl apply -f teams-ui.yaml
echo "Waiting for Teams UI to be ready..."
kubectl wait --namespace engineering-platform --for=condition=ready pod --selector=app=teams-ui --timeout=120s
echo "Teams UI is ready!"