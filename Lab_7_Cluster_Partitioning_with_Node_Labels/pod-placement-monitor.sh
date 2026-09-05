#!/bin/bash

echo "Pod Placement Monitor"
echo "===================="
echo ""

# Function to show pod placement
show_placement() {
    echo "Current Pod Placement:"
    echo "----------------------"
    oc get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,APP:.metadata.labels.app --no-headers | while read pod node app; do
        if [ ! -z "$node" ]; then
            env_label=$(oc get node $node -o jsonpath='{.metadata.labels.environment}' 2>/dev/null)
            workload_label=$(oc get node $node -o jsonpath='{.metadata.labels.workload}' 2>/dev/null)
            echo "Pod: $pod | Node: $node | Environment: $env_label | Workload: $workload_label"
        fi
    done
    echo ""
}

# Function to show node selector compliance
check_compliance() {
    echo "Node Selector Compliance Check:"
    echo "--------------------------------"
    
    # Check production database
    prod_db_node=$(oc get pod -l app=production-database -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null)
    if [ ! -z "$prod_db_node" ]; then
        prod_env=$(oc get node $prod_db_node -o jsonpath='{.metadata.labels.environment}' 2>/dev/null)
        prod_workload=$(oc get node $prod_db_node -o jsonpath='{.metadata.labels.workload}' 2>/dev/null)
        echo "Production DB: Environment=$prod_env, Workload=$prod_workload"
    fi
    
    # Check development webapp
    dev_webapp_node=$(oc get pod -l app=development-webapp -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null)
    if [ ! -z "$dev_webapp_node" ]; then
        dev_env=$(oc get node $dev_webapp_node -o jsonpath='{.metadata.labels.environment}' 2>/dev/null)
        dev_workload=$(oc get node $dev_webapp_node -o jsonpath='{.metadata.labels.workload}' 2>/dev/null)
        echo "Development WebApp: Environment=$dev_env, Workload=$dev_workload"
    fi
    
    # Check testing compute
    test_compute_node=$(oc get pod -l app=testing-compute -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null)
    if [ ! -z "$test_compute_node" ]; then
        test_env=$(oc get node $test_compute_node -o jsonpath='{.metadata.labels.environment}' 2>/dev/null)
        test_workload=$(oc get node $test_compute_node -o jsonpath='{.metadata.labels.workload}' 2>/dev/null)
        test_disk=$(oc get node $test_compute_node -o jsonpath='{.metadata.labels.disk-type}' 2>/dev/null)
        echo "Testing Compute: Environment=$test_env, Workload=$test_workload, Disk=$test_disk"
    fi
}

show_placement
check_compliance
