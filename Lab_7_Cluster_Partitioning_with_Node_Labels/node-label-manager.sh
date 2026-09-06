#!/bin/bash

# Node Label Management Script
echo "OpenShift Node Label Manager"
echo "============================"

# Function to list all nodes with custom labels
list_labeled_nodes() {
    echo "Current node labels:"
    oc get nodes -o custom-columns=NAME:.metadata.name,ENVIRONMENT:.metadata.labels.environment,DISK-TYPE:.metadata.labels.disk-type,WORKLOAD:.metadata.labels.workload
}

# Function to add environment label
add_environment_label() {
    local node=$1
    local env=$2
    echo "Adding environment label '$env' to node '$node'"
    oc label node $node environment=$env --overwrite
}

# Function to remove labels
remove_label() {
    local node=$1
    local label=$2
    echo "Removing label '$label' from node '$node'"
    oc label node $node $label-
}

# Main menu
case $1 in
    "list")
        list_labeled_nodes
        ;;
    "add-env")
        add_environment_label $2 $3
        ;;
    "remove")
        remove_label $2 $3
        ;;
    *)
        echo "Usage: $0 {list|add-env <node> <environment>|remove <node> <label>}"
        echo "Examples:"
        echo "  $0 list"
        echo "  $0 add-env worker-1 production"
        echo "  $0 remove worker-1 environment"
        ;;
esac
