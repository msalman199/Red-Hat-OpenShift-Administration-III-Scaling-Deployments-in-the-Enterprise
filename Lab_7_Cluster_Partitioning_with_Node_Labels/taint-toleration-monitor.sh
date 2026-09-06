#!/bin/bash

echo "Taint and Toleration Monitor"
echo "============================"
echo ""

# Function to show node taints
show_taints() {
    echo "Node Taints:"
    echo "------------"
    for node in $(oc get nodes -o name | cut -d/ -f2); do
        echo "Node: $node"
        taints=$(oc describe node $node | grep "Taints:" | cut -d: -f2- | xargs)
        if [ -z "$taints" ] || [ "$taints" = "<none>" ]; then
            echo "  No taints"
        else
            echo "  Taints: $taints"
        fi
        echo ""
    done
}

# Function to show pod tolerations and scheduling
show_tolerations() {
    echo "Pod Tolerations and Scheduling:"
    echo "-------------------------------"
    
    for pod in $(oc get pods -o name); do
        pod_name=$(echo $pod | cut -d/ -f2)
        app_label=$(oc get $pod -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
        node_name=$(oc get $pod -o jsonpath='{.spec.nodeName}' 2>/dev/null)
        phase=$(oc get $pod -o jsonpath='{.status.phase}' 2>/dev/null)
        
        echo "Pod: $pod_name (App: $app_label)"
        echo "  Status: $phase"
        if [ ! -z "$node_name" ]; then
            echo "  Scheduled on: $node_name"
        else
            echo "  Not scheduled"
        fi
        
        # Show tolerations
        tolerations=$(oc get $pod -o jsonpath='{.spec.tolerations}' 2>/dev/null)
        if [ "$tolerations" != "null" ] && [ ! -z "$tolerations" ]; then
            echo "  Has tolerations: Yes"
        else
            echo "  Has tolerations: No"
        fi
        echo ""
    done
}

# Function to check scheduling issues
check_scheduling_issues() {
    echo "Scheduling Issues:"
    echo "------------------"
    
    pending_pods=$(oc get pods --field-selector=status.phase=Pending -o name 2>/dev/null)
    if [ -z "$pending_pods" ]; then
        echo "No pending pods found."
    else
        echo "Pending pods detected:"
        for pod in $pending_pods; do
            pod_name=$(echo $pod | cut -d/ -f2)
            echo "  - $pod_name"
            # Get the reason for pending
            reason=$(oc describe $pod | grep -A 10 "Events:" | grep "FailedScheduling" | tail -1)
            if [ ! -z "$reason" ]; then
                echo "    Reason: $reason"
            fi
        done
    fi
    echo ""
}

show_taints
show_tolerations
check_scheduling_issues
