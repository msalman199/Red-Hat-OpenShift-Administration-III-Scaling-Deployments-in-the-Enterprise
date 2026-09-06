#!/bin/bash

echo "=== Data Integrity Verification ==="

# Get PostgreSQL pod
POSTGRES_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')

if [ -n "$POSTGRES_POD" ]; then
    echo "Checking database structure..."
    
    # Check tables
    echo "Database tables:"
    oc exec ${POSTGRES_POD} -- psql -U webapp -d webappdb -c "\dt"
    
    # Check data counts (if applicable)
    echo -e "\nChecking data integrity..."
    oc exec ${POSTGRES_POD} -- psql -U webapp -d webappdb -c "SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del FROM pg_stat_user_tables;"
    
    echo "✓ Database verification completed"
else
    echo "✗ Cannot find PostgreSQL pod for verification"
fi
