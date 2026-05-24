# PE Architecture Demo

A Platform Engineering architecture demo running on a local virtual Kubernetes cluster (`vcluster`).

## Prerequisites

- `vcluster` (vind mode with Docker)
- `kubectl`
- `helm`

## Cluster lifecycle

All commands run from the `vind/` directory:

```bash
# Create cluster
cd vind && sudo vcluster create pe-arch-cluster -f pe-arch-cluster.yaml

# Destroy cluster
cd vind && sudo vcluster delete pe-arch-cluster
```

## Bootstrap sequence

Run each step in order from within its directory.

---

### 00 — Ingress (Traefik)

```bash
cd bootstrap/00-ingress-traefik
bash 00-install-traefik.sh
```

Installs Traefik as the default ingress controller into the `traefik` namespace. Configured as the cluster-wide default `IngressClass`, handling both standard Ingress and Traefik CRDs.

**Verify:**

```bash
bash 01-test-traefik.sh
```

Deploys a `whoami` test app and curls `http://whoami.172.18.255.254.sslip.io`. Expects HTTP 200 with echoed request headers.

---

### 01 — Monitoring stack (Prometheus + Grafana + AlertManager)

```bash
cd bootstrap/01-monitoring-stack
bash 00-install-prometheus.sh
```

Installs `kube-prometheus-stack` into the `monitoring` namespace via the `prometheus-community` Helm chart. Includes:

- **Prometheus** — 7d retention, 10Gi storage, 2Gi memory limit
- **Grafana** — admin password `admin123`, 2Gi persistent storage, exposed via Traefik ingress
- **AlertManager** — enabled with modest resource limits
- **Node Exporter** and **kube-state-metrics** — enabled
- etcd, controller-manager, and scheduler metrics — disabled (not accessible in vcluster)

**Access Grafana:**

```
http://grafana.172.18.255.254.sslip.io
Username: admin
Password: admin123
```

**Verify:**

```bash
bash 01-test-grafana.sh
```

Curls the Grafana ingress endpoint. Expects HTTP 200.
