#!/bin/bash

# Default to Langley, BC if no location provided
LOCATION=${1:-Langley,CA}
API_KEY="${OPENWEATHER_API_KEY}"

if [ -z "$API_KEY" ]; then
    echo "Error: OPENWEATHER_API_KEY not set"
    exit 1
fi

# Fetch current weather
WEATHER=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=$LOCATION&units=metric&appid=$API_KEY")

# Parse and display
TEMP=$(echo "$WEATHER" | jq '.main.temp' 2>/dev/null)
FEELS_LIKE=$(echo "$WEATHER" | jq '.main.feels_like' 2>/dev/null)
DESCRIPTION=$(echo "$WEATHER" | jq -r '.weather[0].description' 2>/dev/null)
HUMIDITY=$(echo "$WEATHER" | jq '.main.humidity' 2>/dev/null)
WIND_SPEED=$(echo "$WEATHER" | jq '.wind.speed' 2>/dev/null)

if [ -n "$TEMP" ]; then
    echo "🌤 Weather for $LOCATION:"
    echo "Temperature: ${TEMP}°C"
    echo "Feels Like: ${FEELS_LIKE}°C"
    echo "Conditions: $DESCRIPTION"
    echo "Humidity: ${HUMIDITY}%"
    echo "Wind Speed: ${WIND_SPEED} m/s"
else
    echo "Could not fetch weather data"
fi

# Stocks function
fetch_stocks() {
    TICKERS="AAPL MSFT GOOGL AMZN NVDA META TSLA SHOO PLTR HOOD ORCL"
    for T in $TICKERS; do
        STOCK_DATA=$(curl -s "https://query1.finance.yahoo.com/v8/finance/chart/$T?range=1d&interval=1d")
        PRICE=$(echo "$STOCK_DATA" | jq -r '.chart.result[0].meta.regularMarketPrice // empty')
        PREV=$(echo "$STOCK_DATA" | jq -r '.chart.result[0].meta.chartPreviousClose // empty')
        
        if [ -n "$PRICE" ] && [ -n "$PREV" ]; then
            CHANGE=$(echo "$PRICE $PREV" | awk '{printf "%.2f", $1-$2}')
            PCT=$(echo "$PRICE $PREV" | awk '{printf "%.1f", (($1-$2)/$2)*100}')
            echo "$T: \$$PRICE (${CHANGE} / ${PCT}%)"
        fi
    done
}

# Run stocks if second argument is 'stocks'
[ "$2" = "stocks" ] && fetch_stocks