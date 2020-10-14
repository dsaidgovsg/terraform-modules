ui = "{{ vault_ui_enable }}"

service_registration "consul" {
  address = "127.0.0.1:8500"
}
