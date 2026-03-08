#!/bin/bash

set -e

echo "=== Log in to Keycloak as admin ==="
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin

echo "=== Create realm ==="
/opt/keycloak/bin/kcadm.sh create realms -s realm=authz-code-grant-realm -s enabled=true
/opt/keycloak/bin/kcadm.sh get realms/authz-code-grant-realm --fields 'id,realm'

echo "=== Create user ==="
USER_ID=$(/opt/keycloak/bin/kcadm.sh create users -r authz-code-grant-realm -f /samples/authorization-code-grant/user.json --id)
echo "Created new user with id '${USER_ID}'"
/opt/keycloak/bin/kcadm.sh get "users/${USER_ID}" --fields 'id,username' -r authz-code-grant-realm

echo "=== Set user password ==="
PASSWORD=foofoo
/opt/keycloak/bin/kcadm.sh set-password -r authz-code-grant-realm --username foo --new-password "${PASSWORD}"
echo "Set password for user 'foo' to '${PASSWORD}'"

echo "=== Create client ==="
CLIENT_ID=$(/opt/keycloak/bin/kcadm.sh create clients -r authz-code-grant-realm -f /samples/authorization-code-grant/client.json --id)
echo "Created new client with id '${CLIENT_ID}'"
/opt/keycloak/bin/kcadm.sh get "clients/${CLIENT_ID}" --fields 'id,clientId' -r authz-code-grant-realm

echo "=== Show client secret ==="
echo "Client secret for client 'authz-code-grant-client' is:"
/opt/keycloak/bin/kcadm.sh get "clients/${CLIENT_ID}/client-secret" -r authz-code-grant-realm

echo "=== Keycloak setup completed ==="
