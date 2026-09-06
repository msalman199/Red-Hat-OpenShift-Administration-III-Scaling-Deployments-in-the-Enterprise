#!/bin/bash

# Taint Management Script
echo "OpenShift Taint Manager"
echo "======================"

# Function to list all taints
list_taints() {
    echo "Current Node Taints:"
    echo "-------------------"
    for node in $(oc get nodes -o name | cut -d/ -f2); do
        echo "Node: $node"
        oc describe node $node | grep "Taints:" | sed 's/Taints:/  /'
        echo ""
    done
}

# Function to add taint
add_taint() {
    local node=$1
    local key=$2
    local value=$3
    local effect=$4
    
    if [ -z "$node" ] || [ -z "$key" ] || [ -z "$effect" ]; then
        echo "Usage: add_taint <node> <key> <value> <effect>"
        echo "Effects: NoSchedule, PreferNoSchedule, NoExecute"
        return 1
    fi
    
    if [ -z "$value" ]; then
        echo "Adding taint $key:$effect to node $node"
        oc adm taint node $node $key:$effect
    else
        echo "Adding taint $key=$value:$effect to node $node"
        oc adm taint node $node $key=$value:$effect
    fi
}

# Function to remove taint
remove_taint() {
    local node=$1
    local key=$2
    
    if [ -z "$node" ] || [ -z "$key" ]; then
        echo "Usage: remove_taint <node> <key>"
        return 1
    fi
    
    echo "Removing taint with key '$key' from node '$node'"
    oc adm taint node $node $key-
}

# Function to remove all taints from a node
remove_all_taints() {
    local node=$1
    
    if [ -z "$node" ]; then
        echo "Usage: remove_all_taints <node>"
        return 1
    fi
    
    echo "Removing all taints from node '$node'"
    # Get all taint keys for the node
    taint_keys=$(oc describe node $node | grep "Taints:" | cut -d: -f2- | tr ',' '\n' | cut -d= -f1 | cut -d: -f1 | xargs)
    
    for key in $taint_keys; do
        if [ "$key" != "<none>" ] && [ ! -z "$key" ]; then
            echo "  Removing taint key: $key"
            oc adm taint node $node $key- 2>/dev/null || true
        fi
    done
}

# Main menu
case $1 in
    "list")
        list_taints
        ;;
    "add")
        add_taint $2 $3 $4 $5
        ;;
    "remove")
        remove_taint $2 $3
        ;;
    "remove-all")
        remove_all_taints $2
        ;;
    *)
        echo "Usage: $0 {list|add|remove|remove-all}"
        echo ""
        echo "Commands:"
        echo "  list                           - List all node taints"
        echo "  add <node> <key> <value> <effect> - Add taint to node"
        echo "  remove <node> <key>            - Remove specific taint from node"
        echo "  remove-all <node>              - Remove all taints from node"
        echo ""
        echo "Examples:"
        echo "  $0 list"
        echo "  $0 add worker-1 dedicated production NoSchedule"
        echo "  $0 remove worker-1 dedicated"
        echo "  $0 remove-all worker-1"
        ;;
esac
