# ansible-docker-ubuntu

Simple Ansible Role to install Docker-ce on Ubuntu

## Variables

- `docker_version`: Version of Docker to install
- `docker_compose_version`: Version of Docker Compose to install. Set to empty if you do not want to install Docker Compose.
- `docker_py_version`: Version of the [Docker Pip](https://pypi.python.org/pypi/docker) package to install. This is usually needed to interact with Docker on the remote. Set to empty if you do not wish to install this.
