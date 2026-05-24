#!/bin/bash
# Deploy the whoami test app, service, and ingress to verify routing works end-to-end
kubectl apply -f test-ingress.yaml

# Wait for the whoami pod to become ready before testing
kubectl rollout status deployment/whoami --namespace default --timeout=60s

# Curl the whoami ingress endpoint; sslip.io resolves the embedded IP automatically
# Expected response: HTTP 200 with request headers echoed back by whoami
sleep 5
curl --fail --silent --show-error http://whoami.172.18.255.254.sslip.io
