#!/bin/bash

set -e
export ETCDCTL_API=3

UUID=$1
DRY=${2:-}

[[ -z "$UUID" ]] && { echo "Usage: $0 <volume_uuid> [--dry-run]"; exit 1; }

# Find and update task
TASKS=$(etcdctl get --prefix /registry/tasks/UpdateVolumeTask/ -w json)
for i in $(echo "$TASKS" | jq -r '.kvs | keys[]'); do
    KEY=$(echo "$TASKS" | jq -r ".kvs[$i].key" | base64 -d)
    VALUE=$(echo "$TASKS" | jq -r ".kvs[$i].value" | base64 -d)
    
    if [[ $(echo "$VALUE" | jq -r .ResourceUUID) == "$UUID" ]]; then
        echo "Found task: $KEY"
        [[ $(echo "$VALUE" | jq -r .State) != "Running" ]] && { echo "Not running"; exit 1; }
        
        CT=$(echo "$VALUE" | jq -r .CreationTime)
        NEW=$(echo "$VALUE" | jq --arg ct "$CT" '.State="Completed"|.CompletionTime=$ct')
        
        if [[ "$DRY" == "--dry-run" ]]; then
            echo "Would update: $KEY"
        else
            etcdctl put "$KEY" "$(echo "$NEW" | jq -c .)"
            sleep 1
            # Refresh volume info
            VOL_KEY="/registry/cluster/volumes/$UUID"
            VOL_DATA=$(etcdctl get "$VOL_KEY" | tail -n +2)
            etcdctl put "$VOL_KEY" "$VOL_DATA"
            echo "Updated successfully"
        fi
        exit 0
    fi
done

echo "Volume UUID not found"
exit 1
