# Keycloak Samples

This repository has sample configurations for testing Keycloak. For testing purposes only. Not for production use.

## How to deploy Keycloak

```console
kubectl apply -k .
```

## How to set up Keycloak

### Authorization Code Grant Sample

```console
kubectl exec -it keycloak-0 -- /samples/authorization-code-grant/setup-keycloak.sh
```

### Device Code Grant Sample

```console
kubectl exec -it keycloak-0 -- /samples/device-authorization-grant/setup-keycloak.sh
```

### CockroachDB SSO Sample

See [README](./samples/cockroachdb-sso/README.md) in the `./samples/cockroachdb-sso/` directory.

## How to clean up Keycloak

```console
kubectl delete -k .
```
