FROM jlesage/baseimage-gui:debian-13-v4

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=24 \
    APP_NAME="Wireshark" \
    WIRESHARK_RUN_DUMPCAP_AS_ROOT=1

RUN sed -i "s/UI.initSetting('resize', resize);/UI.initSetting('resize', 'remote');/g" /opt/noVNC/app/ui.js

# Preseed wireshark debconf and install dependencies in one layer
RUN echo "wireshark-common wireshark-common/install-setuid boolean false" | debconf-set-selections && \
    rm -f /etc/passwd /etc/group /etc/shadow /etc/gshadow && \
    cp /usr/share/base-passwd/passwd.master /etc/passwd && \
    cp /usr/share/base-passwd/group.master /etc/group && \
    : > /etc/shadow && : > /etc/gshadow && \
    mkdir -p /config/log /config/var/tmp && \
    apt-get update && \
    apt-get install -y --no-install-recommends wireshark adwaita-qt curl jq ca-certificates && \
    ARCH=$(dpkg --print-architecture) && \
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/siemens/cshargextcap/releases/latest | jq -r .tag_name) && \
    curl -L -o /tmp/cshargextcap.deb "https://github.com/siemens/cshargextcap/releases/download/${LATEST_RELEASE}/cshargextcap_${LATEST_RELEASE#v}_linux_${ARCH}.deb" && \
    apt-get install -y --no-install-recommends /tmp/cshargextcap.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/cshargextcap.deb /config/log /config/var && \
    rm -f /etc/passwd /etc/group /etc/shadow /etc/gshadow && \
    ln -s /tmp/.passwd /etc/passwd && \
    ln -s /tmp/.group /etc/group && \
    ln -s /tmp/.shadow /etc/shadow && \
    ln -s /tmp/.gshadow /etc/gshadow

COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh