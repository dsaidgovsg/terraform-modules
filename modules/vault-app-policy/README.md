# Vault App Policy

This module serves as an addon to add application service policies to access
key / value secrets stored in your already set-up Vault.

## Description

Generate two policies that affect the KV path at `"${var.kv_path}/app/${var.app}"`.

The `app` policy will restrict to only readonly access
The `dev` policy will allow read/write access.

The policies will have the following naming convention if `${var.prefix}` is set as a non-empty
string:

- Read-only  (app): `"${var.prefix}_${var.app}_app"`
- Read-Write (dev): `"${var.prefix}_${var.app}_dev"`

Otherwise, without prefix:

- Read-only  (app): `"${var.app}_app"`
- Read-Write (dev): `"${var.app}_dev"`

__Be sure not to use same app name across all your application services!__

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app | App name to set policy | string | - | yes |
| kv_path | Vault Key/value prefix path to the secrets | string | - | yes |
| prefix | Prefix to prepend to the policy name | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| app_policy | Name of Application level policy |
| app_rendered_content | Vault policy content at Application level |
| dev_policy | Name of Developer level policy |
| dev_rendered_content | Vault policy content at Developer level |
