#!/bin/bash

# Input file containing the URL and data
DATA_FILE="./input/data.json"

# Load URL and data from the JSON file
if [[ -f "$DATA_FILE" ]]; then
    URL=$(jq -r '.url' "$DATA_FILE")
    DATA=$(jq -c '.data' "$DATA_FILE")
    # Check if URL or data is empty
    if [[ -z "$URL" || -z "$DATA" ]]; then
        echo "🛑 Error: URL or data is missing in $DATA_FILE."
        exit 1
    fi
    echo "✅ File $DATA_FILE loaded successfully."
else
    echo "Error: file $DATA_FILE not found."
    exit 1
fi




# Log file
LOG_FILE="./output/request_logs_$(date +%Y%m%d%H%M%S).txt"
# Bid request 
echo -e "⚙️ Bid request:\n\n" >> "$LOG_FILE"
echo "$DATA" | jq>>"$LOG_FILE"
echo -e "\n\n---------------------------------------------------------------------------------------------------------\n\n" >> "$LOG_FILE"
# Loop to send requests
echo "🚀 Sending requests..."

for i in {1..10}; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    # Send POST request
    RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$URL" -H "Content-Type: application/json" -d "$DATA")

    # Extract HTTP status and response body
    HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d':' -f2)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS/d' | jq)

    # Log the response
    echo "[$TIMESTAMP] Request #$i:" >> "$LOG_FILE"
    echo "HTTP Status: $HTTP_STATUS" >> "$LOG_FILE"

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "Response Body: $RESPONSE_BODY" >> "$LOG_FILE"
        echo "Comment: 🟢 BID for this request" >> "$LOG_FILE"
    elif [[ "$HTTP_STATUS" == "204" ]]; then
        echo "Response Body: $RESPONSE_BODY" >> "$LOG_FILE"
        echo "Comment: 🟡 NO BID for this request" >> "$LOG_FILE"
    else
        echo "Response Body: $RESPONSE_BODY" >> "$LOG_FILE"
        echo "Comment: 🔴 ERROR for this request" >> "$LOG_FILE"
        exit 1
    fi

    echo "---------------------------------------------------------------------------------------------------------" >> "$LOG_FILE"
done

echo "👩‍🚀 Requests sent successfully."
echo "💾Logs saved to $LOG_FILE"
