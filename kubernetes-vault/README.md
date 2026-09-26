## Cкрипты инсталляции 

consul:
```
#!/usr/bin/env bash
set -euo pipefail
helm install consul ./consul-k8s-2.0.4/charts/consul \
  -n consul \
  -f consul-values.yaml \
  --skip-crds
```

vault:
```
#!/usr/bin/env bash
set -euo pipefail
helm install vault ./vault-helm-0.34.1 \
  -n vault \
  -f vault-values.yaml \
  --skip-crds
```

eso:
```
#!/usr/bin/env bash
set -euo pipefail
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets \
  -n vault \
  --set installCRDs=true
```