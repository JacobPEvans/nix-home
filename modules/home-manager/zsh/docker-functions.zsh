# Docker utility functions

# docker-exec - Execute bash in a running container
# Usage: docker-exec <container-name>
# Example: docker-exec splunk
docker-exec() {
  # $1 is the container name (e.g. splunk)
  docker exec -it "$1" /bin/bash
}

# docker-run-splunk - Run Splunk container with password
# Usage: docker-run-splunk <password>
# Example: docker-run-splunk 'MyP@ssw0rd!'
docker-run-splunk() {
  # $1 is the password. Special characters are allowed due to the single quotes
  docker run -d --rm --name splunk \
    --platform linux/amd64 \
    -p 8000:8000 -p 8088:8088 -p 9997:9997 \
    -e SPLUNK_START_ARGS='--accept-license' \
    -e SPLUNK_PASSWORD="$1" \
    -e SPLUNK_GENERAL_TERMS='--accept-sgt-current-at-splunk-com' \
    -v splunk-etc:/opt/splunk/etc \
    -v splunk-var:/opt/splunk/var \
    splunk/splunk:latest
}

# docker-run-splunk-v - Run specific version of Splunk container
# Usage: docker-run-splunk-v <password> <version>
# Example: docker-run-splunk-v 'MyP@ssw0rd!' 9.1.0
docker-run-splunk-v() {
  # $1 is the password, $2 is the version
  docker run -d --rm --name splunk \
    --platform linux/amd64 \
    -p 8000:8000 -p 8088:8088 -p 9997:9997 \
    -e SPLUNK_START_ARGS='--accept-license' \
    -e SPLUNK_PASSWORD="$1" \
    -e SPLUNK_GENERAL_TERMS='--accept-sgt-current-at-splunk-com' \
    -v splunk-etc:/opt/splunk/etc \
    -v splunk-var:/opt/splunk/var \
    splunk/splunk:"$2"
}
