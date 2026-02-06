#!/bin/bash

echo "=== Login to Keycloak as admin ==="
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin

echo "=== Create realm ==="
/opt/keycloak/bin/kcadm.sh create realms -s realm=authz-code-grant-realm -s enabled=true

echo "=== Create client ==="
CLIENT_ID=$(/opt/keycloak/bin/kcadm.sh create clients -r authz-code-grant-realm -f /samples/authorization-code-grant/client.json --id)

echo "=== Create user ==="
USER_ID=$(/opt/keycloak/bin/kcadm.sh create users -r authz-code-grant-realm -f /samples/authorization-code-grant/user.json --id)

echo "=== Set user password ==="
/opt/keycloak/bin/kcadm.sh set-password -r authz-code-grant-realm --username foo --new-password foofoo

echo "=== Show client secret ==="
/opt/keycloak/bin/kcadm.sh get clients/${CLIENT_ID}/client-secret -r authz-code-grant-realm

echo "=== Keycloak setup completed ==="
