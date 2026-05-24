# PE Architecture Demo

A Platform Engineering architecture demo running on a local virtual Kubernetes cluster.

## Setup

All cluster lifecycle commands run from the `infrastucture/` directory.

**Create the cluster:**

```bash
cd infrastucture
bash 00-init-cluster.sh
```

**Destroy the cluster:**

```bash
cd infrastucture
bash 01-delete-cluster.sh
```
