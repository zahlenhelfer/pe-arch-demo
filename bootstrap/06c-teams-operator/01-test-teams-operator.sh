#!/bin/bash
echo "====== TEAMS OPERATOR TESTS ========"
echo "Operator Pod:"
kubectl get pods -n engineering-platform -l app=teams-operator
echo ""
echo "Teams in API:"
curl -s http://teams-api.172.18.255.254.sslip.io/teams | jq 'length'
echo ""
echo "Managed Namespaces:"
kubectl get namespaces -l app.kubernetes.io/managed-by=teams-operator --no-headers | wc -l
echo "===================================="
echo "Recent Operator Activity:"
kubectl logs -n engineering-platform deployment/teams-operator --tail=10
echo "===================================="
echo "Now delete a teams namespace"
kubectl delete namespace teams-demo
echo "===================================="
echo "Now checking the operator logs:"
kubectl logs -n engineering-platform deployment/teams-operator -f