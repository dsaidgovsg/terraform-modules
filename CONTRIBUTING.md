# Contributing to Terraform Modules

This repository follows the best practices Conventional Commits since commit
`ae09ec5`, whose specification can be found in:
<https://www.conventionalcommits.org/en/v1.0.0/>.

The repository also prefers all branches to start with the following prefixes:

- `build--`
- `chore--`
- `ci--`
- `feat--`
- `fix--`
- `perf--`
- `refactor--`
- `test--`

The repository also prefers to follow the opinionated max 100 chars for any line
of commit message.

See Angular's
[Commit Message Guidelines](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#-commit-message-guidelines)
to see some practical examples in action.

For the generation of `INOUT.md`, which are basically files containing the value
of `terraform-docs md .` for every Terraform module, you can simply run
`./inout generate` at the root directory. Note that it requires `docker` CLI.
These files are also checked in the CI process to ensure that the inputs and
outputs in the description always tally with the Terraform configuration files.

## Rationale

Enforcing the branch prefix allows every PR to be labeled automatically
according to the Conventional Commit type via GitHub Action.

This indirectly allows the generation of release CHANGELOG to be
done automatically, again via GitHub action.
