#!/bin/bash
# Test the custom rules 
kubectl apply -f copy-fail-demo.yaml
kubectl logs -n copy-fail job/copy-fail -f

# Cleanup
echo "Cleaning up..."
kubectl delete -f copy-fail-demo.yaml
