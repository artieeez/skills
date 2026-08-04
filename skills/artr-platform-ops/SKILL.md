---
name: artr-platform-ops
description: Inspect and diagnose the artr personal platform on OCI Kubernetes (Argo CD apps, workload logs/events, deploy GitHub Actions, cluster reachability). Use when checking Argo health/sync, OutOfSync or Degraded apps, pod/job logs, failed deploy workflows, kube context issues, "what's on artr", or any ops question about the personal cluster. Do NOT use for Terraform provisioning of oracle-cluster, writing/editing GitOps manifests, general app coding, or non-artr infrastructure.
license: CC-BY-4.0
metadata:
  author: Artur Webber
  version: 1.0.0
---

# artr-platform-ops

Operate and diagnose the **artr** personal platform: GitHub Actions → `artr-gitops` → Argo CD → OCI Kubernetes (`oracle-cluster`). Prefer live evidence from the cluster over guessing.

## Safety (non-negotiable)

1. **Read-only by default.** Do not sync, apply, delete, scale, restart, or seal secrets unless the user explicitly asks.
2. **Never invent credentials.** Do not print or paste secrets into chat unless the user asks for a specific secret retrieval and understands the risk.
3. **Say when tools are missing.** If `kubectl`/`gh`/`argocd`/`oci` is absent or auth fails, diagnose and help the user fix it — do not pretend the cluster answered.
4. **Composability.** Manifest edits belong to coding/GitOps work (e.g. codenavi). This skill observes and diagnoses the live path.

## When to load references

Read `references/command-cheatsheet.md` when you are about to run commands (app status, logs, CI, auth bootstrap). Do not load it for pure planning answers.

## Tool decision tree

```
Need live artr state?
├─ App sync/health / OutOfSync / Degraded
│  → kubectl Applications (argoproj.io) first
│  → argocd CLI only if resource-tree / Argo-specific detail is needed AND CLI is logged in
├─ Workload logs / crash / Job failure
│  → kubectl -n <ns> get/describe + logs + events
├─ "Did the deploy CI fail?"
│  → gh run list / gh run view --log-failed on the relevant repo
├─ Can't talk to the cluster at all
│  → kubectl context → nodes → (optional) oci session/CLI sanity
└─ User explicitly asks to sync/restart
   → confirm target, then mutate; summarize result
```

**Default kube context:** `oracle-cluster`. If another context is current, switch or ask before mutating anything.

## Workflow

### 1. Orient

Identify what the user cares about: which app, namespace, host, or repo. Map names using the inventory in the cheatsheet when ambiguous.

Check once per session (or when commands fail):

```bash
kubectl config current-context
kubectl get --raw=/readyz >/dev/null && echo api-ok
```

If not `oracle-cluster` or API fails → go to **Bootstrap**.

### 2. Investigate (pick path)

**Argo app health**

```bash
kubectl -n argocd get applications.argoproj.io
kubectl -n argocd get applications.argoproj.io <app> -o yaml
kubectl -n argocd describe applications.argoproj.io <app>
```

Summarize: sync status, health, last operation, useful conditions/messages. Dig into managed resources only if unhealthy or user asks.

**Workload logs / events**

```bash
kubectl -n <ns> get deploy,sts,ds,job,cronjob,po
kubectl -n <ns> describe <kind>/<name>
kubectl -n <ns> logs <pod> --tail=200
kubectl -n <ns> get events --sort-by=.lastTimestamp | tail -40
```

For CronJobs/Jobs (e.g. backups), inspect the latest Job/Pod, not only the CronJob object.

**Deploy GitHub Actions**

Use when Argo is stuck behind a missing Git change, image tag, or workflow failure:

```bash
gh run list --repo <owner/repo> --limit 10
gh run view <id> --repo <owner/repo> --log-failed
```

Typical repos: `artieeez/artr-gitops`, `artieeez/sitio-rails`, `artieeez/home`, `artieeez/oracle-cluster`. Prefer the repo that produces the artifact or Git change for the failing app.

**Cluster reachability (OCI)**

Only when kubectl cannot reach the API:

```bash
kubectl cluster-info
kubectl get nodes -o wide
oci session validate 2>/dev/null || oci iam region list --output table 2>&1 | head -20
```

Do not deep-dive VCN/LB/Terraform unless the user asks — escalate to infra/Terraform work instead.

### 3. Report

Keep the answer short and evidence-based:

- **Verdict** (healthy / degraded / unreachable / CI failed)
- **Evidence** (1–3 command findings)
- **Next dig** (one concrete step) or **blocker** (auth/tool missing)

### 4. Bootstrap (when tools/auth fail)

| Symptom | Fix path |
|---|---|
| Wrong kube context | `kubectl config use-context oracle-cluster` |
| API unreachable | Check VPN/Tailscale if used; `kubectl get nodes`; optional `oci` session |
| `kubectl` / `gh` / `argocd` missing | Tell user how to install (Homebrew); stop guessing cluster state |
| Need Argo CLI extras | Prefer port-forward + local `admin` over SSO/PocketID: `kubectl -n argocd port-forward svc/argocd-server 8080:80` then `argocd login localhost:8080 --username admin --plaintext` with password from `argocd-initial-admin-secret` |
| `gh` not auth'd | `gh auth login` / `gh auth status` |

Argo UI is `https://argo.artr.com.br` (OIDC via PocketID). Ingress is not Tinyauth-gated; SSO CLI is still flaky — prefer kubectl or local admin for automation.

### 5. Explicit mutations (only if asked)

Examples the user might request: `argocd app sync <app>`, `kubectl -n <ns> rollout restart deploy/<name>`, delete a failed Job pod.

Always restate the target (app/ns/name) before running. Afterward, re-check health/logs and report.

## Examples

### Example 1: App health

User: "is sitio-staging healthy on artr?"

1. Confirm context `oracle-cluster`
2. `kubectl -n argocd get applications.argoproj.io artr-sitio-staging` (and/or child apps)
3. If Degraded/OutOfSync → describe + check pods in `sitio-staging`
4. Report verdict + evidence

### Example 2: Logs

User: "sqlite backup job failing in sitio-production"

1. `kubectl -n sitio-production get cronjob,job,po`
2. Logs on the latest failing Job pod; events if CrashLoop/backoff
3. Report error line + likely cause; do not reseal secrets unless asked

### Example 3: CI then Argo

User: "I pushed but artr didn't update"

1. `gh run list` on the repo that should have built/pushed
2. If CI green → check Argo app sync/health and Git revision on the Application
3. Say whether the break is CI, Git not synced, or runtime

## Troubleshooting

### Error: `The connection to the server ... was refused` / timeout

Cause: wrong context, API down, or network path.
Solution: fix context; `kubectl get nodes`; check Tailscale/OCI reachability; do not invent app status.

### Error: `applications.argoproj.io ... not found`

Cause: wrong app name.
Solution: `kubectl -n argocd get applications.argoproj.io` and match parent/child naming (`artr-*`, `sitio-*`, `platform-*`).

### Error: argocd CLI talks to `localhost:8080` and fails

Cause: stale port-forward context.
Solution: use kubectl for status, or start port-forward and re-login; avoid `--sso` against PocketID unless the user insists.
