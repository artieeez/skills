# artr command cheatsheet

Load this when executing live diagnostics. Prefer read-only commands unless the user explicitly requested a mutation.

## Inventory

### Kube

| Item | Value |
|---|---|
| Context | `oracle-cluster` |
| Argo namespace | `argocd` |
| Argo UI | `https://argo.artr.com.br` |
| GitOps repo | `artieeez/artr-gitops` |
| Terraform (out of skill scope) | `artieeez/oracle-cluster` |

### Namespaces (workloads)

`argocd`, `platform`, `staging`, `production`, `sitio-staging`, `sitio-production`, `monitoring`, `traefik`, `cert-manager`, `sealed-secrets`, `reflector`, `tailscale`, `harbor`, `rustfs`

### Common Argo applications

Parents often look like `artr-root`, `artr-platform`, `artr-staging`, `artr-production`, `artr-sitio-staging`, `artr-sitio-production`, `artr-monitoring`.

Children examples: `platform-tinyauth`, `platform-pocketid`, `sitio-staging-sitio-rails`, `monitoring-kube-prometheus-stack`, `argocd-ingress`.

List all:

```bash
kubectl -n argocd get applications.argoproj.io
```

## Kubectl — Argo Applications

```bash
kubectl config current-context
kubectl config use-context oracle-cluster

kubectl -n argocd get applications.argoproj.io \
  -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status,REV:.status.sync.revision

kubectl -n argocd get applications.argoproj.io <app> -o yaml
kubectl -n argocd describe applications.argoproj.io <app>

# Managed resources snippet (when present on status)
kubectl -n argocd get applications.argoproj.io <app> \
  -o jsonpath='{range .status.resources[*]}{.kind}/{.namespace}/{.name} {.status}{"\n"}{end}'
```

## Kubectl — workloads / logs

```bash
kubectl -n <ns> get deploy,sts,ds,job,cronjob,po -o wide
kubectl -n <ns> describe <kind>/<name>
kubectl -n <ns> logs deploy/<name> --tail=200
kubectl -n <ns> logs <pod> -c <container> --tail=200
kubectl -n <ns> logs <pod> --previous --tail=200
kubectl -n <ns> get events --sort-by=.lastTimestamp | tail -40

# Latest job from a CronJob name prefix
kubectl -n <ns> get jobs --sort-by=.metadata.creationTimestamp
```

## GitHub Actions

```bash
gh auth status
gh run list --repo artieeez/artr-gitops --limit 10
gh run list --repo artieeez/sitio-rails --limit 10
gh run view <run-id> --repo <owner/repo>
gh run view <run-id> --repo <owner/repo> --log-failed
```

## Argo CD CLI (optional)

Prefer kubectl. Use CLI when you need sync (explicit ask) or Argo-only views and login works.

```bash
# Port-forward (separate terminal)
kubectl -n argocd port-forward svc/argocd-server 8080:80

# Admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo

argocd login localhost:8080 --username admin --password '<password>' --plaintext
argocd app list
argocd app get <app>
argocd app logs <app> --tail 100
# Only if user asked:
argocd app sync <app>
```

Public login without SSO (may work with `--grpc-web`):

```bash
argocd login argo.artr.com.br --username admin --password '<password>' --grpc-web
```

Avoid `argocd login --sso` unless the user wants to fight PocketID OIDC from the CLI.

## OCI reachability (light)

```bash
oci session validate 2>&1 | head -20
oci ce cluster list --compartment-id <compartment-ocid> --output table 2>&1 | head -20
kubectl get nodes -o wide
kubectl get --raw=/readyz?verbose
```

If Terraform/state changes are required, stop and treat that as `oracle-cluster` infra work — outside this skill's default scope.

## Auth notes

- Argo CD uses PocketID as OIDC IdP (`argocd-cm`); the IngressRoute itself has no Tinyauth ForwardAuth.
- Tinyauth protects other apps (e.g. staging/home, pihole), not the Argo API path used by kubectl Application reads.
