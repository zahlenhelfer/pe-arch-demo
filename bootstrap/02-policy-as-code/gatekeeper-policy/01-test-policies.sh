#!/bin/bash
# create a namespace for testing
kubectl create ns team-policy

# This should fail
echo "----------------------------------------------------"
echo "Applying test-costcenter-fail.yaml, this should fail"
kubectl apply -f test-costcenter-fail.yaml
echo "----------------------------------------------------"
echo "Applying test-costcenter-pass.yaml, this should pass"
# This should pass
kubectl apply -f test-costcenter-pass.yaml
echo "----------------------------------------------------"
kubectl delete ns team-policy