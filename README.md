# Keycloak Samples

## How to deploy Keycloak

```console
kubectl apply -k .
```

## How to setup Keycloak

### Authorization Code Grant Sample

```console
kubectl exec -it keycloak-0 -- /samples/authorization-code-grant/setup-keycloak.sh
```

### Device Code Grant Sample

```console
kubectl exec -it keycloak-0 -- /samples/device-authorization-grant/setup-keycloak.sh
```
