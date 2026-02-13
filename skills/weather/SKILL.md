# Weather Skill

## Requirements
- jq (for JSON parsing)
- curl (for network requests)
- OpenWeatherMap API key

## Configuration
1. Get API key from https://openweathermap.org
2. Set environment variable: `OPENWEATHER_API_KEY`
3. Location defaults to Langley, BC, Canada

## Commands
- `weather`: Current conditions
- `forecast`: 5-day forecast
- `stocks`: Fetch stock prices