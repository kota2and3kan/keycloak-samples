#!/bin/bash

set -e

echo "=== Log in to Keycloak as admin ==="
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin

echo "=== Create realm ==="
/opt/keycloak/bin/kcadm.sh create realms -s realm=cockroachdb-sso-realm -s enabled=true
/opt/keycloak/bin/kcadm.sh get realms/cockroachdb-sso-realm --fields 'id,realm'

echo "=== Create client scope ==="
CLIENT_SCOPE_ID=$(/opt/keycloak/bin/kcadm.sh create client-scopes -r cockroachdb-sso-realm -f /samples/cockroachdb-sso/client-scope.json --id)
echo "Created new client scope with id '${CLIENT_SCOPE_ID}'"
/opt/keycloak/bin/kcadm.sh get "client-scopes/${CLIENT_SCOPE_ID}" --fields 'id,name' -r cockroachdb-sso-realm

echo "=== Create user profile ==="
/opt/keycloak/bin/kcadm.sh update realms/cockroachdb-sso-realm/users/profile -f /samples/cockroachdb-sso/profile.json

echo "=== Create user 'goki' ==="
USER_ID_GOKI=$(/opt/keycloak/bin/kcadm.sh create users -r cockroachdb-sso-realm -f /samples/cockroachdb-sso/user-goki.json --id)
echo "Created new user with id '${USER_ID_GOKI}'"
/opt/keycloak/bin/kcadm.sh get "users/${USER_ID_GOKI}" --fields 'id,username' -r cockroachdb-sso-realm

echo "=== Create user 'buri' ==="
USER_ID_BURI=$(/opt/keycloak/bin/kcadm.sh create users -r cockroachdb-sso-realm -f /samples/cockroachdb-sso/user-buri.json --id)
echo "Created new user with id '${USER_ID_BURI}'"
/opt/keycloak/bin/kcadm.sh get "users/${USER_ID_BURI}" --fields 'id,username' -r cockroachdb-sso-realm

echo "=== Set user password ==="
PASSWORD_GOKI=goki
/opt/keycloak/bin/kcadm.sh set-password -r cockroachdb-sso-realm --username goki --new-password "${PASSWORD_GOKI}"
echo "Set password for user 'goki' to '${PASSWORD_GOKI}'"
PASSWORD_BURI=buri
/opt/keycloak/bin/kcadm.sh set-password -r cockroachdb-sso-realm --username buri --new-password "${PASSWORD_BURI}"
echo "Set password for user 'buri' to '${PASSWORD_BURI}'"

echo "=== Create client ==="
CLIENT_ID=$(/opt/keycloak/bin/kcadm.sh create clients -r cockroachdb-sso-realm -f /samples/cockroachdb-sso/client.json --id)
echo "Created new client with id '${CLIENT_ID}'"
/opt/keycloak/bin/kcadm.sh get "clients/${CLIENT_ID}" --fields 'id,clientId' -r cockroachdb-sso-realm

echo "=== Show client secret ==="
echo "Client secret for client 'cockroachdb-sso-client' is:"
/opt/keycloak/bin/kcadm.sh get "clients/${CLIENT_ID}/client-secret" -r cockroachdb-sso-realm

echo "=== Keycloak setup completed ==="
