#!/bin/bash

echo "Test 1 - Checking the Docs"
curl http://teams-api.172.18.255.254.sslip.io/openapi.json | jq

echo "Test 2 - Checking the Health Endpoint"
curl http://teams-api.172.18.255.254.sslip.io/health

echo "Test 3 - Testing Teams API by Creating a Team"
curl -X POST "http://teams-api.172.18.255.254.sslip.io/teams" -H "Content-Type: application/json" '{"name": "Demo-Team"}'

echo "Test 4 - Listing All Teams to Verify Creation"
curl http://teams-api.172.18.255.254.sslip.io/teams | jq

echo "Test 5 - Testing Missing Fields"
curl -X POST "http://teams-api.172.18.255.254.sslip.io/teams" -H "Content-Type: application/json" -d '{}'

echo "Test 6 - Testing Duplicate Team Creation"
curl -X POST "http://teams-api.172.18.255.254.sslip.io/teams" -H "Content-Type: application/json" -d '{"name": "Duplicate-Test"}'
curl -X POST "http://teams-api.172.18.255.254.sslip.io/teams" -H "Content-Type: application/json" -d '{"name": "Duplicate-Test"}'

