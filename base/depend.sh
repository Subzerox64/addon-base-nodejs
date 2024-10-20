#!/bin/bash
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
