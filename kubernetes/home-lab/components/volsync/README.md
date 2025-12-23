# Volsync Component

This is a Kustomize component for deploying Volsync resources with Restic backups.

## Features

- **ReplicationSource** - Automatically backs up your PVC on a schedule
- **ReplicationDestination** - Standby for restore operations (triggered manually when needed)

## How It Works

The component adds backup/restore capabilities to an existing PVC:

1. **Your HelmRelease creates the PVC** (normal Kubernetes PVC)
2. **ReplicationSource** backs it up according to schedule
3. **ReplicationDestination** stands by, ready to restore if needed (doesn't interfere with normal operation)

## Usage

### Step 1: Create the PVC in your HelmRelease

Your app creates storage normally:

```yaml
# In your helm-release.yaml
values:
  persistence:
    config:
      enabled: true
      size: 5Gi
      storageClass: local-hostpath
      accessMode: ReadWriteOnce
```

### Step 2: Add the volsync component

```yaml
# In your app's kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: your-namespace
resources:
  - ./helm-release.yaml
  - ./sops-secret.yaml  # Your encrypted Restic credentials
components:
  - ../../../../components/volsync
```

### Step 3: Configure backup settings

```yaml
# In your app's ks.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: your-app
spec:
  # ... other fields
  postBuild:
    substitute:
      APP: your-app-config  # Must match PVC name created by HelmRelease
      node: your-node       # Node name for scheduling backups
      VOLSYNC_SCHEDULE: "0 9 * * *"    # Backup schedule (daily at 9 AM UTC)
      VOLSYNC_CAPACITY: 5Gi             # Must match PVC size
      VOLSYNC_RETAIN_DAILY: "14"        # Keep 14 daily backups
```

That's it! Backups will run automatically.

## Customization

The component uses substitution variables with default values using the `${VAR:=default}` syntax:

| Variable | Default | Description |
|----------|---------|-------------|
| `APP` | (required) | Application name for PVC and resources |
| `node` | (required) | Node name for affinity scheduling |
| `VOLSYNC_SCHEDULE` | `0 9 * * *` | Cron schedule (daily at 9 UTC) |
| `VOLSYNC_COPYMETHOD` | `Snapshot` | Copy method (Snapshot, Direct, Clone, None) |
| `VOLSYNC_PRUNE_INTERVAL` | `14` | Days between repository pruning |
| `VOLSYNC_RETAIN_DAILY` | `14` | Number of daily backups to retain |
| `VOLSYNC_RETAIN_WITHIN` | `14d` | Keep all backups within this period |
| `VOLSYNC_CAPACITY` | `5Gi` | PVC and cache capacity |
| `VOLSYNC_STORAGECLASS` | `local-hostpath` | Storage class for PVC |
| `VOLSYNC_ACCESSMODES` | `ReadWriteOnce` | PVC access mode |
| `VOLSYNC_PUID` | `1000` | User ID for mover pod |
| `VOLSYNC_PGID` | `1000` | Group ID for mover pod |
| `VOLSYNC_RESTORE_TRIGGER` | `restore-once` | Restore trigger value |

### Overriding Defaults

Variables are passed via Flux's postBuild substitution. The component uses defaults for any variables not provided:

```yaml
# In your app's ks.yaml
postBuild:
  substitute:
    APP: my-app
    node: node1
    VOLSYNC_SCHEDULE: "0 3 * * *"  # 3 AM daily
    VOLSYNC_CAPACITY: 10Gi
    VOLSYNC_RETAIN_DAILY: "30"
```

## Secret Configuration

1. Copy the `secret.yaml` template from the component to your app directory
2. Fill in your actual values:
   - `RESTIC_REPOSITORY`: Your backup destination (S3, B2, local path, etc.)
   - `RESTIC_PASSWORD`: Encryption password for your backup
   - `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`: If using S3-compatible storage
3. Encrypt it with SOPS:
   ```bash
   cd kubernetes/home-lab/apps/your-app/app
   sops --encrypt --age $(cat ../../../../age.enc.agekey | age-keygen -y) sops-secret.yaml > sops-secret.enc.yaml
   ```
4. Update your app's kustomization.yaml to reference `sops-secret.enc.yaml` instead of `sops-secret.yaml`

## Example

See the test app for a complete working example:
- `kubernetes/home-lab/apps/test/test-volsync/`

Or see the existing production apps:
- `kubernetes/home-lab/apps/media/plex/app/`
- `kubernetes/home-lab/apps/media/calibre/app/`

## Restore from Backup

To restore data from a backup (disaster recovery):

1. **Scale down the app** to stop writes:
   ```bash
   kubectl scale statefulset your-app -n your-namespace --replicas=0
   ```

2. **Delete the PVC** (this will delete the data - make sure you have backups!):
   ```bash
   kubectl delete pvc your-app-config -n your-namespace
   ```

3. **Trigger a restore** by updating the ReplicationDestination:
   ```bash
   kubectl patch replicationdestination your-app-config-dst -n your-namespace \
     --type merge -p '{"spec":{"trigger":{"manual":"restore-'$(date +%s)'"}}}'
   ```

4. **Wait for restore** to complete:
   ```bash
   kubectl wait --for=condition=Synchronizing replicationdestination/your-app-config-dst \
     -n your-namespace --timeout=10m
   ```

5. **Recreate the PVC** - The restored data is in a temporary PVC. You need to create your app's PVC and copy data, OR let volsync create it. (Check volsync documentation for the exact restore workflow for Restic)

6. **Scale up the app**:
   ```bash
   kubectl scale statefulset your-app -n your-namespace --replicas=1
   ```

**Note**: The exact restore procedure depends on your volsync configuration. See volsync documentation for Restic-specific restore workflows.
