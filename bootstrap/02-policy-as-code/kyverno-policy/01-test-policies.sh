#!/bin/bash

# This should fail
echo "---------------------------------------------------------"
echo "Applying test-networkpolicy.yaml"
kubectl get networkpolicy -A
kubectl create ns team-policy
kubectl get networkpolicy -n team-policy
echo "---------------------------------------------------------"
echo "Applying test-image-signature-pass.yaml, this should pass"
echo "---------------------------------------------------------"
kubectl apply -f test-image-signature-pass.yaml
echo "---------------------------------------------------------"
echo "Applying test-image-signature-fail.yaml, this should fail"
echo "---------------------------------------------------------"
kubectl apply -f test-image-signature-fail.yaml
echo "---------------------------------------------------------"
echo "Cleaning up Namespace"
kubectl delete ns team-policy