#!/bin/bash
echo "========================================"
echo "Testing Grafana"
echo "========================================"
echo "use your browser to navigate to:"
echo "http://grafana.172.18.255.254.sslip.io"
echo "========================================"
echo "Testing Grafana via curl"
curl --fail --silent --show-error http://grafana.172.18.255.254.sslip.io