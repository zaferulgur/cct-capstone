#!/bin/bash

set -o xtrace

export KUBELET_CONFIG_JSON_FILE="/etc/kubernetes/kubelet/kubelet-config.json"

echo "DevOps was here...."

declare -A kubelet_configs
kubelet_configs=( 
    ["imageMinimumGCAge"]="\"10m0s\""
    ["imageGCHighThresholdPercent"]="65"
    ["imageGCLowThresholdPercent"]="20"
    ["maxPerPodContainerCount"]="1"
    ["maxContainerCount"]="2"
)

# iterate over keys
for KUBELET_CONFIG_KEY in "${!kubelet_configs[@]}"; do
    export KUBELET_CONFIG_VALUE="${kubelet_configs[$KUBELET_CONFIG_KEY]}"

    if grep -q "$KUBELET_CONFIG_KEY" "$KUBELET_CONFIG_JSON_FILE"; then
        echo "$KUBELET_CONFIG_KEY is exist."
        sed -i. "s/\"$KUBELET_CONFIG_KEY.*/\"$KUBELET_CONFIG_KEY\": $KUBELET_CONFIG_VALUE,/g" "$KUBELET_CONFIG_JSON_FILE"
    else
        echo "$KUBELET_CONFIG_KEY does not exist!!!"
        sed -i. "/\"apiVersion.*/ a\ \"$KUBELET_CONFIG_KEY\": $KUBELET_CONFIG_VALUE," "$KUBELET_CONFIG_JSON_FILE"
    fi
done
