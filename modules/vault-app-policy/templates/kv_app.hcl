########################################
# Read only access for Apps on KV store
########################################
path "${kv_path}" {
    capabilities = ["read", "list"]
}

path "${kv_path}/*" {
    capabilities = ["read", "list"]
}

