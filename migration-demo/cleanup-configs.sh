#!/bin/bash

echo "Cleaning up configuration files for new cluster..."

# Function to clean YAML files
clean_yaml() {
    local file=$1
    echo "Cleaning $file..."
    
    # Remove cluster-specific metadata
    yq eval 'del(.items[].metadata.uid)' -i $file
    yq eval 'del(.items[].metadata.resourceVersion)' -i $file
    yq eval 'del(.items[].metadata.generation)' -i $file
    yq eval 'del(.items[].metadata.creationTimestamp)' -i $file
    yq eval 'del(.items[].metadata.selfLink)' -i $file
    yq eval 'del(.items[].status)' -i $file
    
    # Remove annotations that might cause conflicts
    yq eval 'del(.items[].metadata.annotations."deployment.kubernetes.io/revision")' -i $file
    yq eval 'del(.items[].metadata.annotations."kubectl.kubernetes.io/last-applied-configuration")' -i $file
}

# Install yq if not present
if ! command -v yq &> /dev/null; then
    echo "Installing yq..."
    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    chmod +x /usr/local/bin/yq
fi

# Clean all configuration files
for file in configs/*.yaml; do
    if [ -f "$file" ]; then
        clean_yaml "$file"
    fi
done

echo "Configuration cleanup completed!"
