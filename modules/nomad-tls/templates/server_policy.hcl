path "${pki_path}/issue/${role}" {
  capabilities = ["create", "update"]
}

path "${gossip_path}" {
  capabilities = ["read"]
}
