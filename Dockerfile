FROM telegraf:latest

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3.7 python3-pip python3-setuptools python3-wheel && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install requests pyyaml

ARG ALPINE_VERSION=3.7
FROM alpine:${ALPINE_VERSION}

MAINTAINER SignalFx Support <support+collectd@signalfx.com>

# Specify Versions
ARG COLLECTD_STAGE=release
ARG PLUGIN_STAGE=release
ARG ALPINE_VERSION=3.7

# Setup our collectd
COPY ["configs", "/tmp/"]

# Add public repository key
COPY ["support+apk@signalfx.com-57fbc71c.rsa.pub", "/etc/apk/keys"]

# Install all apt-get utils and required repos
COPY ["install.sh", "/" ]
RUN chmod +x /install.sh && \
    /install.sh $ALPINE_VERSION $COLLECTD_STAGE $PLUGIN_STAGE && \
    rm -f /install.sh

# Add in startup script
COPY ["run.sh", "/run/"]

# Make run script executable
RUN chmod +x /run/run.sh

# Set the shell as the entry point
ENTRYPOINT /run/run.sh
