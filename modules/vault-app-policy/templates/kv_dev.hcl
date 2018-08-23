########################################
# Developer analogue policy for the apps KV store
########################################
path "${kv_path}" {
    capabilities = ["read", "list", "create", "update", "delete"]
}

path "${kv_path}/*" {
    capabilities = ["read", "list", "create", "update", "delete"]
}
