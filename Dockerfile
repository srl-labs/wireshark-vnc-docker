FROM jlesage/baseimage-gui:ubuntu-24.04-v4

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
    apt-get update && \
    apt-get install -y --no-install-recommends curl jq ca-certificates && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xA2E402B85A4B70CD78D8A3D9D875551314ECA0F0" -o /etc/apt/keyrings/wireshark-dev.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/wireshark-dev.asc] https://ppa.launchpadcontent.net/wireshark-dev/stable/ubuntu noble main" > /etc/apt/sources.list.d/wireshark-dev.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends wireshark adwaita-qt && \
    ARCH=$(dpkg --print-architecture) && \
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/siemens/cshargextcap/releases/latest | jq -r .tag_name) && \
    curl -L -o /tmp/cshargextcap.deb "https://github.com/siemens/cshargextcap/releases/download/${LATEST_RELEASE}/cshargextcap_${LATEST_RELEASE#v}_linux_${ARCH}.deb" && \
    apt-get install -y --no-install-recommends /tmp/cshargextcap.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/cshargextcap.deb

COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh