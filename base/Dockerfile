ARG BUILD_FROM=node:18.20.4-alpine3.19
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Environment variables
ENV \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    HOME="/root" \
    LANG="C.UTF-8" \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_EXTRA_INDEX_URL="https://wheels.home-assistant.io/musllinux-index/" \
    PIP_NO_CACHE_DIR=1 \
    PIP_PREFER_BINARY=1 \
    PS1="$(whoami)@$(hostname):$(pwd)$ " \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    YARN_HTTP_TIMEOUT=1000000 \
    TERM="xterm-256color" 

RUN apk add --no-cache bash


RUN  #!/bin/bash
set -eo pipefail

# Update APK repository
apk update

# Install build dependencies
apk add --no-cache --virtual .build-dependencies \
    tar=1.35-r2 \
    xz=5.4.5-r0

# Install runtime dependencies
apk add --no-cache \
    libcrypto3=3.1.7-r0 \
    libssl3=3.1.7-r0 \
    musl-utils=1.2.4_git20230717-r4 \
    musl=1.2.4_git20230717-r4 \
    libstdc++=13.2.1_git20231014-r0 \
    bash=5.2.21-r0 \
    curl=8.9.1-r1 \
    jq=1.7.1-r0 \
    tzdata=2024a-r0

# Determine architecture
S6_ARCH="${BUILD_ARCH}"
case "${BUILD_ARCH}" in
    "i386") S6_ARCH="i686" ;;
    "amd64") S6_ARCH="x86_64" ;;
    "armv7") S6_ARCH="arm" ;;
esac

# Download and extract s6-overlay
for ARCH in noarch ${S6_ARCH} symlinks-noarch symlinks-arch; do
    curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.xz" | tar -C / -Jxpf -
done

# Download and install bashio
curl -J -L -o /tmp/bashio.tar.gz "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz"
mkdir /tmp/bashio
tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio
mv /tmp/bashio/lib /usr/lib/bashio
ln -s /usr/lib/bashio/bashio /usr/bin/bashio

# Download and install tempio
curl -L -s -o /usr/bin/tempio "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"
chmod a+x /usr/bin/tempio

# Clean up
apk del --no-cache --purge .build-dependencies
rm -f -r /tmp/*


# Copy root filesystem
COPY rootfs /

# Copy s6-overlay adjustments
COPY s6-overlay /package/admin/s6-overlay-${S6_OVERLAY_VERSION}/

# Entrypoint & CMD
ENTRYPOINT ["/init"]

# Build arugments
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION
ARG BUILD_REPOSITORY

# Labels
LABEL \
    io.hass.name="Addon NodeJS base for ${BUILD_ARCH}" \
    io.hass.description="Home Assistant Community Add-on: ${BUILD_ARCH} NodeJS base image" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="base" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.title="Addon NodeJS base for ${BUILD_ARCH}" \
    org.opencontainers.image.description="Home Assistant Community Add-on: ${BUILD_ARCH} NodeJS base image" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
