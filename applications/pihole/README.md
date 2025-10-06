# Pi-hole Deployment with Kubenix

This directory contains kubenix configuration files to generate Kubernetes manifests for deploying Pi-hole.

## Files

- `flake.nix` - Nix flake configuration with kubenix inputs and build outputs
- `pihole.nix` - Main kubenix configuration defining all Kubernetes resources
- `README.md` - This file

## Prerequisites

1. Install Nix with flakes enabled
2. Have kubectl configured for your cluster
3. Ensure your cluster has:
   - A storage class named `oci` (or update the PVC configuration)
   - An ingress controller (if using the ingress)
   - cert-manager (if using TLS)

## Configuration

### Storage Class
Update the `storageClassName` in the PVC configuration in `pihole.nix` to match your cluster's available storage classes.

### Password
Change the default admin password in the secret configuration in `pihole.nix`.

### DNS Settings
Modify the custom DNS settings in the ConfigMap to add your local domain mappings.

### Ingress
Update the hostname in the ingress configuration to match your domain.

## Usage

### Build the manifests
```bash
make build
# or directly: nix build
```

### Apply to cluster
```bash
make apply
```

### Delete from cluster
```bash
make delete
```

### View deployment status
```bash
make status
```

### View generated manifests
```bash
cat result/*.yaml
```

### Show logs
```bash
make logs
```

### Development shell
```bash
make shell
# or directly: nix develop
```

### Show all available commands
```bash
make help
```

## Customization

The configuration includes:

- **Namespace**: `pihole`
- **Storage**: 1Gi PVC for Pi-hole data persistence
- **Services**: 
  - DNS service (LoadBalancer for external access)
  - Web interface service (ClusterIP)
- **Ingress**: HTTPS access with Let's Encrypt certificates
- **ConfigMaps**: Custom DNS settings and Pi-hole FTL configuration
- **Resources**: CPU and memory limits/requests

### DNS Configuration

The deployment includes:
- Custom DNS mappings via ConfigMap
- Upstream DNS servers (Cloudflare and Google)
- DNS listening on all interfaces

### Web Interface

- Accessible via ingress at `https://pihole.arendse.nom.za`
- Admin password set via Kubernetes secret
- Health checks configured

## Notes

- The deployment uses `strategy.type: Recreate` to avoid conflicts with persistent storage
- DNS policy is set to `None` with custom DNS config to prevent loops
- Pi-hole data persists across pod restarts via PVC
- Custom dnsmasq configuration can be added via the ConfigMap

## Troubleshooting

1. Check pod logs: `kubectl logs -n pihole deployment/pihole`
2. Verify PVC is bound: `kubectl get pvc -n pihole`
3. Check service endpoints: `kubectl get svc -n pihole`
4. Verify ingress: `kubectl get ingress -n pihole`

## Security Considerations

- Change the default admin password
- Consider using a more secure password storage method (e.g., external secrets)
- Review and adjust resource limits based on your usage
- Configure appropriate network policies if needed