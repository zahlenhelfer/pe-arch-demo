#!/bin/bash
echo "---------------------------------------------------------"
echo "Installing Kyverno policies..."
echo "---------------------------------------------------------"
echo "First: Networkpolicy Generator"
kubectl apply -f kyverno-networkpolicy.yaml
echo "---------------------------------------------------------"
echo "Second: Image signature verification"
kubectl apply -f kyverno-verify-image-signatures.yaml
echo "---------------------------------------------------------"
echo "Done installing Kyverno policies."
