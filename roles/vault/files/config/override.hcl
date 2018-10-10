ha_storage "consul" {
    path = "{{ consul_key }}"
}

ui = "{{ vault_ui_enable }}"
proxy_protocol_behavior = "use_always"
