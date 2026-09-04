#!/bin/bash

mkdir -p /pcaps
cd /pcaps

if [ -n "${CLABWIRE_CAPTURE_PIPE:-}" ] && [ -n "${PACKETFLIX_LINK:-}" ]; then
    echo "CLABWIRE_CAPTURE_PIPE and PACKETFLIX_LINK cannot both be set" >&2
    exit 1
fi

# named pipe to stream the packets from clabwire
if [ -n "${CLABWIRE_CAPTURE_PIPE:-}" ]; then
    capture_dir=$(dirname -- "$CLABWIRE_CAPTURE_PIPE")
    mkdir -p "$capture_dir"

    if [ -e "$CLABWIRE_CAPTURE_PIPE" ] && [ ! -p "$CLABWIRE_CAPTURE_PIPE" ]; then
        echo "CLABWIRE_CAPTURE_PIPE exists and is not a named pipe: $CLABWIRE_CAPTURE_PIPE" >&2
        exit 1
    fi

    if [ ! -p "$CLABWIRE_CAPTURE_PIPE" ]; then
        mkfifo -- "$CLABWIRE_CAPTURE_PIPE"
    fi

    exec /usr/bin/wireshark -k -i "$CLABWIRE_CAPTURE_PIPE"
# Use the packetflix link if provided
elif [ -n "${PACKETFLIX_LINK:-}" ]; then
    exec /usr/bin/wireshark -k -i packetflix -o "extcap.packetflix.url:${PACKETFLIX_LINK}"
else
    exec /usr/bin/wireshark
fi