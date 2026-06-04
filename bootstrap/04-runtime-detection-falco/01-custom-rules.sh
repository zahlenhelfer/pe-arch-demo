#!/bin/bash
helm upgrade falco falcosecurity/falco \
  --namespace falco-system \
  --set driver.kind=modern_ebpf \
  --set falcosidekick.enabled=true \
  --set-file customRules."my-custom-rules\.yaml"=./root-detect-rule.yaml \
  --set-file customRules."cve-2026-31431-copy-fail-rules\.yaml"=./cve-2026-31431-copy-fail-rules.yaml
