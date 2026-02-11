# Keycloak Samples

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

## How to clean up Keycloak

```console
kubectl delete -k .
```
