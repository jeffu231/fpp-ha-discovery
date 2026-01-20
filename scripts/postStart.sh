#!/bin/bash

. ${FPPDIR}/scripts/common

logOutput

echo "Running fpp-ha-discovery PostStart Script"

# Fetch all the settings
MQTTHost=$(getSetting MQTTHost)
MQTTPort=${MQTTPort:-1883}
MQTTPrefix=$(getSetting MQTTPrefix)
MQTTUsername=$(getSetting MQTTUsername)
MQTTCaFile=$(getSetting MQTTCaFile)
MQTTPassword=$(getSetting MQTTPassword)

if { [ -z "$MQTTHost" ] || [ "$MQTTHost" == "0" ]; } ; then
    echo "MQTT Host is not configured. Please configure MQTT settings in FPP before using this plugin."
    exit 1
fi


MachineIdPath="/etc/machine-id"

MachineId=$(cat "$MachineIdPath")

MachineId=${MachineId: -10}

# Fetch JSON data from an API (using the -s flag for silent mode to suppress progress meter)
JsonResponse=$(curl -s "http://localhost/api/system/info")

# Check if the request was successful before parsing 
if [ $? -eq 0 ]; then
    # Parse specific values using jq
    # .key_name accesses top-level keys
    # .key_name[] iterates through array elements
    # -r flag outputs the raw string (without quotes)

    Platform=$(echo "$JsonResponse" | jq -r '.Platform')
    Variant=$(echo "$JsonResponse" | jq -r '.Variant')
    Version=$(echo "$JsonResponse" | jq -r '.Version')

    echo "Platform: $Platform"
    echo "Variant: $Variant"
    echo "Version: $Version"
else
    echo "Failed to retrieve data from the system info payload."
fi

DeviceId="fpp_${MachineId}"

if [ -z "$Variant" ] || [ "$Variant" == "null" ] ; then
    Variant="(Unknown)"
fi

Model="${Platform} ${Variant}"

# Device and Sensor details
DeviceName=$(hostname)

DiscoveryTopic="homeassistant/device/${DeviceId}/config"

DiscoveryPayload='{
    "device":{
        "ids": ["'"${DeviceId}"'"],
        "name": "'"${DeviceName}"'",
        "mf": "'"${Platform}"'",
        "mdl": "'"${Model}"'",
        "sw": "'"${Version}"'",
        "hw": "'"${Platform}"'"
    },
    "origin": {
        "name": "Falcon Player",
        "sw": "'"${Version}"'",
        "url": "https://falconchristmas.com/fpp/"
    },
    "components": {
        "version":{
            "name": "Version",
            "p": "sensor",
            "ent_cat": "diagnostic",
            "def_ent_id": "'"sensor.${DeviceName}_version"'",
            "unique_id": "'"mqtt_${DeviceId}_version"'",
            "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/version"'",
            "qos": 1
        },
        "mode":{
            "name": "Mode",
            "p": "sensor",
            "def_ent_id": "'"sensor.${DeviceName}_mode"'",
            "unique_id": "'"mqtt_${DeviceId}_mode"'",
            "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/fppd_status"'",
            "value_template": "{{ value_json.mode_name }}",
            "qos": 1
        },
        "git_branch":{
            "name": "Git Branch",
            "p": "sensor",
            "ent_cat": "diagnostic",
            "def_ent_id": "'"sensor.${DeviceName}_git_branch"'",
            "unique_id": "'"mqtt_${DeviceId}_git_branch"'",
            "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/branch"'",
            "qos": 1
        },
        "warnings":{
            "name": "Warnings",
            "p": "sensor",
            "def_ent_id": "'"sensor.${DeviceName}_warnings"'",
            "unique_id": "'"mqtt_${DeviceId}_warnings"'",
            "ent_cat": "diagnostic",
            "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/warnings"'",
            "value_template": " {{ value_json|length }}",
            "json_attributes_topic": "9_barbarotto/lightshow/falcon/player/fpp/warnings",
            "json_attributes_template": "'"{ "warnings": {{ value }} }"'",
            "qos": 1
        },
        "fppd_status":{
            "name": "FPPD Status",
            "p": "sensor",
            "ent_cat": "diagnostic",
            "def_ent_id": "'"sensor.${DeviceName}_fppd_status"'",
            "unique_id": "'"mqtt_${DeviceId}_fppd_status"'",
            "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/fppd_status"'",
            "value_template": "{{ value_json.fppd }}",
            "qos": 1
        },
        "status":{
            "name": "Status",
            "p": "sensor",
            "def_ent_id": "'"sensor.${DeviceName}_status"'",
            "unique_id": "'"mqtt_${DeviceId}_status"'",
            "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/fppd_status"'",
            "value_template": "{{ value_json.status_name }}",
            "json_attributes_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/fppd_status"'",
            "qos": 1
        },
        "sequence":{
            "name": "Sequence",
            "p": "sensor",
            "def_ent_id": "'"sensor.${DeviceName}_sequence"'",
            "unique_id": "'"mqtt_${DeviceId}_sequence"'",
            "value_template": "{{ value_json.current_sequence }}",
            "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/fppd_status"'",
            "availability": {
                "topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/fppd_status"'",
                "payload_available": "1",
                "payload_not_available": "0",
                "value_template": "{{ value_json.status }}"
            },
            "qos": 1
        },
        "playlist":{
            "name": "Playlist",
            "p": "sensor",
            "def_ent_id": "'"sensor.${DeviceName}_playlist"'",
            "unique_id": "'"mqtt_${DeviceId}_playlist"'",
            "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/playlist/name/status"'",
            "availability": {
                "topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/fppd_status"'",
                "payload_available": "1",
                "payload_not_available": "0",
                "value_template": "{{ value_json.status }}"
            },
            "qos": 1
        }
    },
    "state_topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/ready"'",
    "availability": {
        "topic": "'"$MQTTPrefix/falcon/player/${DeviceName}/ready"'",
        "payload_available": "1",
        "payload_not_available": "0",
        "value_template": "{{ value }}",
        "qos": 1
    },
    "qos": 1
}'

echo "Configured MQTT host: $MQTTHost"
echo "Configured MQTT port: $MQTTPort"
echo "Configured MQTT topic prefix: $MQTTPrefix"

# Publish the configuration payload to the MQTT broker with retain flag set
mosquitto_pub -h "$MQTTHost" -p "$MQTTPort" -u "$MQTTUsername" -P "$MQTTPassword" -t "$DiscoveryTopic" -m "$DiscoveryPayload" -r

echo "Published MQTT discovery payload for $DeviceName and with device id: $DeviceId to topic $DiscoveryTopic"

