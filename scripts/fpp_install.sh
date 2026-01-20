#!/bin/bash

. ${FPPDIR}/scripts/common

echo "Running fpp-ha-discovery Install Script"

# Check to see if jq is installed so we can parse json
if [ "$(dpkg-query -W --showformat='${db:Status-Status}' jq 2>/dev/null)" = "installed" ]; then
    echo "jq is installed."
else
    echo "jq is not installed so we will install it now."
    apt install jq -y
    if [ $? -eq 0 ]; then
        echo "Package jq installed successfully."
    else
        echo "Package jq installation failed."
        exit 1
    fi
fi

# Fetch MQTT broker setting to ensure we have a broker configured
MQTTHost=$(getSetting MQTTHost)

if { [ -z "$MQTTHost" ] || [ "$MQTTHost" == "0" ]; } ; then
    echo "MQTT Host is not configured. Please configure MQTT settings in FPP before using this plugin."
else
    echo "MQTT is already configured"
fi

setSetting restartFlag 1
