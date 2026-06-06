#!/bin/bash
echo "========================================"
echo "Testing Teams UI"
echo "========================================"
echo "use your browser to navigate to:"
echo "http://teams-ui.172.18.255.254.sslip.io"
echo "---------------------------------------"
echo "Login with Keycloak credentials:"
echo "Username: teamlead1@company.com"
echo "Password: password123"
echo "========================================"
echo "Testing Teams UI via curl:"
curl -s http://teams-ui.172.18.255.254.sslip.io
echo "========================================"
