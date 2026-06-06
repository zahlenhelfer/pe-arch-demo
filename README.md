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

---

### 02 — Policy as Code (Gatekeeper + Kyverno)

```bash
cd bootstrap/02-policy-as-code
bash 00-install-gatekeeper.sh
bash 01-install-kyverno.sh
```

Installs two policy engines into the cluster:

- **OPA Gatekeeper** (`gatekeeper-system` namespace) — enforces cost-center label requirements on team namespaces via a `ConstraintTemplate` + `K8sRequiredLabels` constraint
- **Kyverno** (`kyverno` namespace) — enforces network policies and image signature verification

After install, apply the policies:

```bash
cd bootstrap/02-policy-as-code/gatekeeper-policy
bash 00-install-policies.sh

cd ../kyverno-policy
bash 00-install-policies.sh
```

**Verify:**

```bash
bash 01-test-policies.sh   # from each policy subdirectory
```

---

### 03 — Metrics Server

```bash
cd bootstrap/03-metrics-server
bash 00-install-metrics-server.sh
```

Installs `metrics-server` into `kube-system` with `--kubelet-insecure-tls` (lab/dev environment only). Enables `kubectl top nodes` and `kubectl top pods`.

**Verify:**

```bash
bash 01-test-metrics.sh
```

Runs `kubectl top nodes` to confirm metrics are being collected.

---

### 04 — Runtime Detection (Falco)

```bash
cd bootstrap/04-runtime-detection-falco
bash 00-install-falco.sh
```

Installs Falco as a DaemonSet into `falco-system` using the modern eBPF driver, with Falcosidekick enabled for event forwarding.

After install, apply custom detection rules:

```bash
bash 01-custom-rules.sh
```

Loads two rule sets:
- **Root detection rules** — alerts on processes running as UID 0
- **CVE-2026-31431 rules** — detects the "copy.fail" privilege escalation exploit chain (AF_ALG socket open → splice() page cache manipulation → setuid(0) → setuid binary execution)

**Test detection:**

```bash
bash 02-test-rules.sh
```

---

### 05 — IAM (Keycloak)

```bash
cd bootstrap/05-iam-keycloak
bash 00-install-keycloak.sh
```

Deploys Keycloak with a PostgreSQL backend into the `keycloak` namespace. A pre-seeded `teams` realm is mounted as a ConfigMap with two users:

| User | Password |
|------|----------|
| `admin` | `admin123` |
| `teamlead1@company.com` | `password123` |

**Access:**

```
http://platform-auth.172.18.255.254.sslip.io
```

> **Note:** Before applying `keycloak-deployment.yaml`, replace `<workspace-name>` in the OIDC redirect/web-origin URIs with the actual Coder workspace hostname.

---

### 06a — Teams API

```bash
cd bootstrap/06a-teams-api
bash 00-install-teams-api.sh
```

Deploys the Teams API into the `engineering-platform` namespace. Exposed via Traefik ingress.

**Access:**

```
http://teams-api.172.18.255.254.sslip.io
```

**Verify:**

```bash
bash 01-test-teams-api.sh
```

Runs a series of curl tests: OpenAPI docs, health endpoint, team creation, listing, missing fields, and duplicate detection.

---

### 06b — Teams CLI

```bash
cd bootstrap/06b-teams-cli
bash 00-get-cli.sh
```

Downloads the `teams-cli` binary (macOS ARM64) from GitHub releases and installs it to `/usr/local/bin/teams-cli`.

**Usage:**

```bash
teams-cli --help
teams-cli --version
```

---

### 06c — Teams Operator

```bash
cd bootstrap/06c-teams-operator
bash 00-install-teams-operator.sh
```

Deploys the Teams Operator into the `engineering-platform` namespace. It polls the Teams API every 30 seconds and reconciles Kubernetes namespaces to match team state. Holds a `ClusterRole` with full namespace management permissions.

**Verify:**

```bash
bash 01-test-teams-operator.sh
```

Shows operator pod status, team count from the API, managed namespace count, and recent operator logs.

---

### 06d — Teams UI

```bash
cd bootstrap/06d-teams-ui
bash 00-install-teams-ui.sh
```

Deploys the Teams UI (3 replicas) into the `engineering-platform` namespace. Connects to `teams-api-service:4200` and authenticates via Keycloak.

**Access:**

```
http://teams-ui.172.18.255.254.sslip.io
Username: teamlead1@company.com
Password: password123
```

**Verify:**

```bash
bash 01-test-teams-ui.sh
```

---

## Architecture

```
engineering-platform namespace
  teams-ui (3 replicas, :80) → teams-api-service:4200 → teams-api (:8000)
  teams-operator (polls API every 30s, creates/manages namespaces via ClusterRole)

keycloak namespace
  keycloak (:8080, realm: "teams") → keycloak-postgres-service:5432
```

## Ingress endpoints summary

| Service | URL |
|---------|-----|
| Grafana | `http://grafana.172.18.255.254.sslip.io` |
| Keycloak | `http://platform-auth.172.18.255.254.sslip.io` |
| Teams API | `http://teams-api.172.18.255.254.sslip.io` |
| Teams UI | `http://teams-ui.172.18.255.254.sslip.io` |
