#!/bin/bash
set -eu

# Define the JSON file location
WEATHER="/home/$(whoami)/ZDotfiles/conky/weather.json"

# Extract temperatures
temp_min=$(jq '.main.temp_min' $WEATHER)
temp_max=$(jq '.main.temp_max' $WEATHER)

# Calculate the average temperature
temp_avg=$(echo "scale=2; ($temp_min + $temp_max)/2" | bc)

# Print the results based on the command line argument
case "$1" in
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
