#!/bin/bash
echo "Installing Gatekeeper policies..."
kubectl apply -f team-namespace-costcenter-constraint.yaml
kubectl apply -f team-namespace-costcenter-template.yaml
echo "...Gatekeeper Policies installed successfully."