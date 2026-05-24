#!/bin/bash

# Test
echo "Metrics Server installed successfully. Waiting for it to start collecting metrics..."
kubectl top nodes
