# Bootstrap 04 — Runtime Detection with Falco

Installs Falco (eBPF driver) into the cluster and applies custom detection rules, including a demo rule set for CVE-2026-31431 (`copy.fail`).

## Files

| File | Purpose |
|---|---|
| `falco-values.yaml` | Helm values (eBPF driver, Falcosidekick, Prometheus metrics) |
| `00-install-falco.sh` | Initial Falco installation |
| `01-custom-rules.sh` | Loads custom rules into Falco via Helm upgrade |
| `root-detect-rule.yaml` | Rule: detect root process execution in containers |
| `cve-2026-31431-copy-fail-rules.yaml` | Rules: detect CVE-2026-31431 exploit chain |
| `gatekeeper-falcorootprevention-constraint-template.yaml` | Gatekeeper ConstraintTemplate: block root containers |
| `gatekeeper-enforce-falco-root-prevention-constraint.yaml` | Gatekeeper Constraint: enforce root prevention |
| `copy-fail-demo.yaml` | Demo Job for testing CVE-2026-31431 detection rules |

---

## Installation

Run scripts from within this directory.

### 1. Install Falco

```bash
cd bootstrap/04-runtime-detection-falco
bash 00-install-falco.sh
```

### 2. Load custom rules

```bash
bash 01-custom-rules.sh
```

Wait for the DaemonSet rollout to complete:

```bash
kubectl rollout status daemonset/falco -n falco-system
```

### 3. Apply Gatekeeper policies

```bash
kubectl apply -f gatekeeper-falcorootprevention-constraint-template.yaml
kubectl apply -f gatekeeper-enforce-falco-root-prevention-constraint.yaml
```

---

## Testing CVE-2026-31431 detection (`copy.fail`)

### About the exploit

CVE-2026-31431 (`copy.fail`) achieves unprivileged → root inside a container by chaining three kernel primitives:

1. **AF_ALG socket** — opens the kernel crypto API (family 38)
2. **splice()** — manipulates the page cache of a setuid binary
3. **setuid(0)** — completes privilege escalation from the modified page

The PoC is a Python-only script, so Rule 4 additionally detects Python spawning setuid binaries (`su`, `sudo`, etc.).

### Detection rules summary

| Rule | Trigger | Falco level |
|---|---|---|
| AF_ALG Socket in Container | `socket(AF_ALG)` succeeds inside a container | CRITICAL |
| Suspicious splice Syscall | `splice()` called by uid != 0 inside a container | WARNING |
| Privilege Escalation via setuid | `setuid(0)` called by uid != 0 inside a container | CRITICAL |
| Python Spawning Setuid Binary | Python process spawns `su`, `sudo`, etc. | CRITICAL |

### Step-by-step test

**Step 1 — Make sure custom rules are loaded** (see Installation above).

**Step 2 — Open a terminal and tail Falco logs:**

```bash
kubectl logs -n falco-system -l app.kubernetes.io/name=falco -f | grep CVE-2026-31431 | jq
```

**Step 3 — In a second terminal, deploy the demo Job:**

```bash
kubectl apply -f copy-fail-demo.yaml
```

**Step 4 — Watch the Job output:**

```bash
kubectl logs -n copy-fail job/copy-fail -f
```

Expected Job output:

```
=== CVE-2026-31431 copy.fail detection test ===
[1] Opening AF_ALG socket (family 38)...
[1] OK — Rule 1 should fire (CRITICAL: CVE-2026-31431 AF_ALG Socket)
[2] Calling splice() via ctypes...
[2] OK (splice returned 1024) — Rule 2 should fire (WARNING: CVE-2026-31431 splice)
[3] Calling setuid(0) (will be denied)...
[3] OK (denied with EPERM) — Rule 3 should fire (CRITICAL: CVE-2026-31431 setuid)
[4] Spawning su from Python...
[4] OK (su exited 1) — Rule 4 should fire (CRITICAL: CVE-2026-31431 Python Spawning Setuid)

=== Test complete — check Falco logs for 4 alerts ===
```

**Step 5 — Verify all 4 alerts in the Falco terminal:**

```
CVE-2026-31431: AF_ALG socket opened in container — exploit stage 1 ...
CVE-2026-31431: splice() called by unprivileged process in container — possible exploit stage 2 ...
CVE-2026-31431: unprivileged process called setuid(0) in container — exploit likely succeeded ...
CVE-2026-31431: Python spawned setuid binary in container — PoC execution pattern detected ...
```

### Cleanup

```bash
kubectl delete -f copy-fail-demo.yaml
```

The Job also auto-deletes after 10 minutes (`ttlSecondsAfterFinished: 600`).

### Note on Rule 1

Rule 1 requires `evt.res >= 0` — the AF_ALG socket must be successfully created. This requires `CONFIG_CRYPTO_USER_API` in the kernel (standard in most distributions) and the `Unconfined` seccomp profile set on the demo Job. If Rule 1 does not fire, check that `01-custom-rules.sh` was run after the CVE rules file was added.
