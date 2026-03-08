#!/bin/bash

set -e

echo "=== Log in to Keycloak as admin ==="
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin

echo "=== Create realm ==="
/opt/keycloak/bin/kcadm.sh create realms -s realm=device-authz-grant-realm -s enabled=true
/opt/keycloak/bin/kcadm.sh get realms/device-authz-grant-realm --fields 'id,realm'

echo "=== Create user ==="
USER_ID=$(/opt/keycloak/bin/kcadm.sh create users -r device-authz-grant-realm -f /samples/device-authorization-grant/user.json --id)
echo "Created new user with id '${USER_ID}'"
/opt/keycloak/bin/kcadm.sh get "users/${USER_ID}" --fields 'id,username' -r device-authz-grant-realm

echo "=== Set user password ==="
PASSWORD=foofoo
/opt/keycloak/bin/kcadm.sh set-password -r device-authz-grant-realm --username foo --new-password "${PASSWORD}"
echo "Set password for user 'foo' to '${PASSWORD}'"

echo "=== Create client ==="
CLIENT_ID=$(/opt/keycloak/bin/kcadm.sh create clients -r device-authz-grant-realm -f /samples/device-authorization-grant/client.json --id)
echo "Created new client with id '${CLIENT_ID}'"
/opt/keycloak/bin/kcadm.sh get "clients/${CLIENT_ID}" --fields 'id,clientId' -r device-authz-grant-realm

echo "=== Show client secret ==="
echo "Client secret for client 'device-authz-grant-client' is:"
/opt/keycloak/bin/kcadm.sh get "clients/${CLIENT_ID}/client-secret" -r device-authz-grant-realm

echo "=== Keycloak setup completed ==="
