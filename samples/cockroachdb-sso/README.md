# CockroachDB SSO Sample

## Prerequisites

This sample assumes that you are using minikube for the testing. Please run the `minikube tunnel` command to access both Keycloak and CockroachDB DB Console through the `127.0.0.1`.

```console
minikube tunnel
```

## How to set up Keycloak

1. Change the listen port of the Keycloak service from `8888` to `80` since CockroachDB supports only `80` or `443` in the user auto provisioning feature for now.

    ```console
    kubectl patch svc keycloak --type='json' -p '[{"op": "replace", "path": "/spec/ports/0/port", "value": 80}]'
    ```

1. Set up Keycloak (Realm, Client Scope, User Profile, Users, and Client).

    ```console
    kubectl exec -it keycloak-0 -- /samples/cockroachdb-sso/setup-keycloak.sh
    ```

## How to set up CockroachDB

1. Navigate to the `./samples/cockroachdb-sso/` directory.

    ```console
    cd ./samples/cockroachdb-sso/
    ```

1. Deploy a CockroachDB cluster by using Helm.

    ```console
    helm repo add cockroachdb https://charts.cockroachdb.com/
    ```

    ```console
    helm repo update
    ```

    ```console
    helm install cockroachdb cockroachdb/cockroachdb -f ./cockroachdb/cockroachdb.yaml --version 20.0.0
    ```

1. Deploy a client pod to run SQL CLI.

    ```console
    kubectl apply -f ./cockroachdb/client.yaml
    ```

1. Set up CockroachDB.

    ```console
    kubectl exec -it cockroachdb-client -- ./cockroach sql --certs-dir=./cockroach-certs --host=cockroachdb-public --file /setup/setup-sso.sql
    ```

## How to set up OS if you run this sample in local environment

You need to be able to access Keycloak through the URL `http://keycloak/realms/cockroachdb-sso-realm` from a browser.

For example, if you use Windows OS, you need to set the following value in the `hosts` file.

```
127.0.0.1 keycloak
```

## Access the DB Console of CockroachDB through authentication by Keycloak

You can access the DB Console of CockroachDB through the following URL:

```
http://localhost:8080/
```

You can select the `Log in with Keycloak` button to log in to the CockroachDB DB Console through Keycloak authentication.

## Access the SQL interface of CockroachDB through authentication by Keycloak

Get an ID token from Keycloak through Device Authorization Grant, and access the CockroachDB SQL interface by using the ID token.

1. Run [Device Authorization Request (RFC 8628 - Section 3.1)](https://datatracker.ietf.org/doc/html/rfc8628#section-3.1), and get [Device Authorization Response (RFC 8628 - Section 3.2)](https://datatracker.ietf.org/doc/html/rfc8628#section-3.2).

    ```console
    DEVICE_AUTHORIZATION_RESPONSE=$(curl -s -XPOST \
      -d 'client_id=cockroachdb-sso-client' \
      -d 'client_secret=cockroachdb-sso-sample-client-password' \
      -d 'scope=openid crdb' \
      -d 'nonce=cockroachdb-sso-nonce' \
      http://keycloak/realms/cockroachdb-sso-realm/protocol/openid-connect/auth/device)
    ```

1. Get a user code.

    ```console
    echo "${DEVICE_AUTHORIZATION_RESPONSE}" | jq -r '.user_code'
    ```

1. Get the verification URL and access it, and enter the user code.

    ```console
    echo "${DEVICE_AUTHORIZATION_RESPONSE}" | jq -r '.verification_uri'
    ```

1. Run [Device Access Token Request (RFC 8628 - Section 3.4)](https://datatracker.ietf.org/doc/html/rfc8628#section-3.4), and get [Device Access Token Response (RFC 8628 - Section 3.5)](https://datatracker.ietf.org/doc/html/rfc8628#section-3.5)

    ```console
    DEVICE_ACCESS_TOKEN_RESPONSE=$(curl -s -XPOST \
      -d 'client_id=cockroachdb-sso-client' \
      -d 'client_secret=cockroachdb-sso-sample-client-password' \
      -d 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code' \
      -d "device_code=$(echo "${DEVICE_AUTHORIZATION_RESPONSE}" | jq -r '.device_code')" \
      http://keycloak/realms/cockroachdb-sso-realm/protocol/openid-connect/token)
    ```

1. Set the ID token to the environment variable `COCKROACHDB_SSO_JWT`.

    ```console
    COCKROACHDB_SSO_JWT=$(echo "${DEVICE_ACCESS_TOKEN_RESPONSE}" | jq -r '.id_token')
    ```

    If you want to see the actual ID token, run the following command:

    ```console
    echo ${COCKROACHDB_SSO_JWT}
    ```

1. Run SQL CLI with the ID token.

    - If you logged in to Keycloak with user `goki`.

      ```console
      kubectl exec -it cockroachdb-client -- ./cockroach sql --url "postgresql://goki:${COCKROACHDB_SSO_JWT}@cockroachdb-public:26257?options=--crdb:jwt_auth_enabled=true" --certs-dir=./cockroach-certs
      ```

    - If you logged in to Keycloak with user `buri`.

      ```console
      kubectl exec -it cockroachdb-client -- ./cockroach sql --url "postgresql://buri:${COCKROACHDB_SSO_JWT}@cockroachdb-public:26257?options=--crdb:jwt_auth_enabled=true" --certs-dir=./cockroach-certs
      ```
