###########Update Volumes Fixer############

Simple bash script to update etcd volume task states from "Running" to "Completed" and refresh volume cluster info.

Requirements

etcdctl (in PATH)
jq

Installation

# RHEL
sudo yum install jq

# Basic usage
./update-volumes-fixer.sh <volume_uuid>

# Dry run
./update-volumes-fixer.sh <volume_uuid> --dry-run

# Example
./update-volumes-fixer.sh 12345678-1234-1234-1234-123456789012
