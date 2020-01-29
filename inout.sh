#!/usr/bin/env sh
print_usage () {
    cat << EOF
Usage: $0 <check|generate> [docker|native]

  Actions
    - check:    Recursively checks for diff between present INOUT.md to current state in module
    - generate: Recursively generates INOUT.md from current state in module

  Mode
    - docker:   Uses Docker container to perform the action (default)
    - native:   Assumes host has exact set-up as cytopia/terraform-docs to perform the action

EOF
}

CHECK_CMD="echo Checking {}... && (cd {} && /docker-entrypoint.sh terraform-docs md . | diff -B INOUT.md - && echo - {}/INOUT.md OKAY!)"
GENERATE_CMD='(cd {} && /docker-entrypoint.sh terraform-docs md . > INOUT.md && chown "${HOSTUID}:${HOSTGID}" INOUT.md && echo Generated {}/INOUT.md!)'

# Use host to find all the non-vendor and cached directories that have at least one .tf file
# and executes the given command for each directory found
native_exec_in_tf_dirs () {
    cmd="$1"
    find . \
        -not -path '*/\.*' \
        -not -path './vendor/*' \
        -type f -iname '*.tf' \
        -exec dirname {} \; | uniq | sort | \
        xargs -I{} sh -c "${cmd}"
    return $?
}

# Use Docker container to find all the non-vendor and cached directories that have at least one .tf file
# and executes the given command for each directory found
docker_exec_in_tf_dirs () {
    cmd="$1"
    docker run --rm -t \
        -v "$(pwd):/data" \
        -e "HOSTUID=$(id -u)" \
        -e "HOSTGID=$(id -g)" \
        --entrypoint sh \
        cytopia/terraform-docs:0.8.0 -c \
        "find . \
            -not -path '*/\.*' \
            -not -path './vendor/*' \
            -type f -iname '*.tf' \
            -exec dirname {} \; | uniq | sort | \
            xargs -I{} sh -c \"${cmd}\""
    return $?
}

exec_in_tf_dirs () {
    cmd="$1"
    mode="$2"

    # Early return all error cases first
    if [ "${mode}" != "docker" ] && [ "${mode}" != "native" ]; then
        # This is an impossible case when calling from CLI
        2>&1 echo 'Mode must be "docker" or "native"!'
        exit 3
    fi

    if [ "${mode}" = "docker" ] && ! command -v "docker" >/dev/null; then
        2>&1 echo "Docker not found, cannot run the command!"
        exit 4
    fi

    if [ "${mode}" = "native" ] && [ ! -f "/docker-entrypoint.sh" ]; then
        2>&1 echo "Missing /docker-entrypoint.sh, host set-up cannot run the command!"
        exit 4
    fi

    # Valid cases
    if [ "${mode}" = "docker" ]; then
        docker_exec_in_tf_dirs "${cmd}"
    else
        native_exec_in_tf_dirs "${cmd}"
    fi

    return $?
}

# Checks every INOUT.md in every tf dir to see if not updated or missing
check () {
    mode="$1"
    exec_in_tf_dirs "${CHECK_CMD}" "${mode}"
    return $?
}

# Generates INOUT.md for every tf dir
generate () {
    mode="$1"
    exec_in_tf_dirs "${GENERATE_CMD}" "${mode}"
    return $?
}

# Main function
if [ "$#" -gt 2 ]; then
    print_usage
    exit 1
fi

case "$1" in
    check) CMD=check
        ;;
    generate) CMD=generate
        ;;
    *) print_usage && exit 2
        ;;
esac

case "$2" in
    docker) MODE=docker
        ;;
    native) MODE=native
        ;;
    '') MODE=docker  # Default is docker
        ;;
    *) print_usage && exit 2
        ;;
esac

"${CMD}" "${MODE}"  # Run the command
