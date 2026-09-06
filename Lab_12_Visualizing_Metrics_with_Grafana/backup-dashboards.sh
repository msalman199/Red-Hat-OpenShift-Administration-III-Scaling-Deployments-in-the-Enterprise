#!/bin/bash
GRAFANA_URL="http://$(oc get route grafana-route -o jsonpath='{.spec.host}')"
API_KEY="your-api-key-here"

# Get list of dashboards
curl -H "Authorization: Bearer $API_KEY" \
     "$GRAFANA_URL/api/search?type=dash-db" | \
     jq -r '.[] | .uid' | \
while read uid; do
    echo "Backing up dashboard: $uid"
    curl -H "Authorization: Bearer $API_KEY" \
         "$GRAFANA_URL/api/dashboards/uid/$uid" | \
         jq '.dashboard' > "dashboard-$uid.json"
done
