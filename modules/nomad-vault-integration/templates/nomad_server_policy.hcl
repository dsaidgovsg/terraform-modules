##########################################################
# Policy to allow the creation of a token to pass to Nomad servers
# From https://www.nomadproject.io/docs/vault-integration/index.html
##########################################################

# Allow creating tokens under "nomad-server" token role. The token role name
# should be updated if "nomad-cluster" is not used.
path "auth/token/create/${nomad_server_role}" {
  capabilities = ["update"]
}

# Allow looking up "nomad-cluster" token role. The token role name should be
# updated if "nomad-cluster" is not used.
path "auth/token/roles/${nomad_server_role}" {
  capabilities = ["read"]
}
