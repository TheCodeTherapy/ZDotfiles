#!/bin/bash
# $1 is '1' for tomorrow or '2' for the day after
# $2 is 'min', 'avg', or 'max'

DAY_OFFSET=$1

# Define the JSON file location
FORECAST="/home/$(whoami)/ZDotfiles/dotfiles/conky/forecast.json"

# Calculate start and end times for the target day
start_of_day=$(date -u +%s -d "$DAY_OFFSET day 00:00")
end_of_day=$(date -u +%s -d "$(($DAY_OFFSET + 1)) day 00:00")

# Extract temperature data for the specified day
temps=$(jq --argjson start $start_of_day --argjson end $end_of_day \
    '.list[] | select(.dt >= $start and .dt < $end) | .main.temp_min, .main.temp_max' $FORECAST)

# Compute min, max, and average temperatures
temp_min=$(echo "$temps" | jq -s 'min')
temp_max=$(echo "$temps" | jq -s 'max')
temp_avg=$(echo "$temps" | jq -s 'add/length')

# Print the results based on the command line argument, formatted to two decimal places
case "$2" in
    min)
        printf "%.1f°C\n" $temp_min
        ;;
    avg)
        printf "%.1f°C\n" $temp_avg
        ;;
    max)
        printf "%.1f°C\n" $temp_max
        ;;
    *)
        echo "Invalid argument. Please specify 'min', 'avg', or 'max'."
        exit 1
        ;;
esac
