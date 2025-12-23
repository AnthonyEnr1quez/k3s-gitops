# Test Volsync Application

This is a test application demonstrating the use of the volsync component for backups.

## What This App Does

- Deploys a simple nginx container as a StatefulSet
- Creates a 1Gi PVC (`test-volsync-config`) backed by `local-hostpath` storage via the HelmRelease
- Uses the volsync component to backup the PVC every hour to a Restic repository
- Retains 7 daily backups

## Files

- `helm-release.yaml` - Helm release for nginx test app (creates the PVC normally)
- `kustomization.yaml` - Includes the volsync component for backups
- `sops-secret.yaml` - Template for Restic repository credentials (needs encryption)
- `ks.yaml` - Flux Kustomization with volsync variables in postBuild.substitute

## How It Works

1. **HelmRelease creates the PVC** - The app defines its storage needs normally in the helm-release.yaml
2. **Volsync component adds backups** - The component creates a ReplicationSource that backs up the PVC
3. **Scheduled backups** - Volsync automatically backs up the PVC hourly to the Restic repository

## Volsync Configuration

The app uses the volsync component with these settings (configured in `ks.yaml`):

```yaml
postBuild:
  substitute:
    APP: test-volsync-config  # PVC name
    node: mina                # Node for scheduling
    VOLSYNC_SCHEDULE: "0 * * * *"  # Hourly backups
    VOLSYNC_CAPACITY: 1Gi     # PVC size
    VOLSYNC_RETAIN_DAILY: "7" # Keep 7 daily backups
```

Other volsync settings use defaults from the component:
- **Copy Method**: `Snapshot`
- **Prune Interval**: 14 days
- **Storage Class**: `local-hostpath`
- **Access Modes**: `ReadWriteOnce`
- **User/Group/FSGroup**: 1000

## Setup Instructions

1. **Encrypt the secret** (before deploying):
   ```bash
   cd kubernetes/home-lab/apps/test/test-volsync/app
   # Edit sops-secret.yaml with your actual Restic repository values
   sops --encrypt --age $(cat ../../../../age.enc.agekey | age-keygen -y) sops-secret.yaml > sops-secret.enc.yaml
   # Update kustomization.yaml to reference sops-secret.enc.yaml instead of sops-secret.yaml
   ```

2. **Deploy**:
   The app will be automatically deployed by Flux when the changes are pushed to git.

3. **Verify**:
   ```bash
   # Check the deployment
   kubectl -n test get pods,pvc,replicationsource
   
   # Check volsync backup status
   kubectl -n test get replicationsource test-volsync-config -o yaml
   
   # View backup logs
   kubectl -n test logs -l volsync.backube/replicationsource=test-volsync-config
   ```

## Resources Created

When deployed, this app creates:

- `HelmRelease/test-volsync` - The nginx application
- `StatefulSet/test-volsync` - The nginx pod
- `PVC/test-volsync-config` - 1Gi persistent volume
- `ReplicationSource/test-volsync-config` - Volsync backup config (hourly)
- `ReplicationDestination/test-volsync-config-dst` - For restore operations
- `SopsSecret/test-volsync-config` - Restic repository credentials

## Testing Restore

To test restoring from backup:

1. Scale down the app: `kubectl -n test scale statefulset test-volsync --replicas=0`
2. Delete the PVC: `kubectl -n test delete pvc test-volsync-config`
3. Trigger a restore by updating the ReplicationDestination:
   ```bash
   kubectl -n test patch replicationdestination test-volsync-config-dst \
     --type merge -p '{"spec":{"trigger":{"manual":"restore-'$(date +%s)'"}}}'
   ```
4. Wait for restore to complete: `kubectl -n test get replicationdestination test-volsync-config-dst -w`
5. Scale up the app: `kubectl -n test scale statefulset test-volsync --replicas=1`

See the volsync component README for more details.
