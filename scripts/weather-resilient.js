#!/usr/bin/env node

/**
 * Resilient Weather Service
 * Handles failures gracefully with multiple fallback options
 */

const { exec } = require('child_process');
const fs = require('fs').promises;
const path = require('path');

const CACHE_FILE = path.join(process.env.HOME, '.openclaw/cache/weather.json');
const CACHE_MAX_AGE = 3600000; // 1 hour

// Utility: Execute command with timeout
function execWithTimeout(command, timeout = 5000) {
  return new Promise((resolve, reject) => {
    const child = exec(command, (error, stdout, stderr) => {
      if (error) reject(error);
      else resolve(stdout.trim());
    });
    
    setTimeout(() => {
      child.kill('SIGTERM');
      reject(new Error('Command timeout'));
    }, timeout);
  });
}

// Service: wttr.in
async function getWeatherWttr(location) {
  const url = `wttr.in/${encodeURIComponent(location)}?format=%l:+%c+%t+%h+%w`;
  const result = await execWithTimeout(`curl -s "${url}"`, 3000);
  
  if (!result || result.includes('Unknown location')) {
    throw new Error('Invalid location or service error');
  }
  
  return {
    source: 'wttr.in',
    location,
    text: result,
    timestamp: Date.now()
  };
}

// Service: Open-Meteo
async function getWeatherOpenMeteo(location) {
  // For demo, using Langley BC coordinates
  // In production, would geocode the location first
  const coords = { lat: 49.1, lon: -122.7 };
  const url = `https://api.open-meteo.com/v1/forecast?latitude=${coords.lat}&longitude=${coords.lon}&current_weather=true`;
  
  const result = await execWithTimeout(`curl -s "${url}"`, 3000);
  const data = JSON.parse(result);
  
  if (!data.current_weather) {
    throw new Error('Invalid response from Open-Meteo');
  }
  
  const weather = data.current_weather;
  const conditions = {
    0: 'Clear',
    1: 'Mainly clear', 
    2: 'Partly cloudy',
    3: 'Overcast',
    45: 'Foggy',
    48: 'Depositing rime fog',
    51: 'Light drizzle',
    61: 'Light rain',
    71: 'Light snow',
    95: 'Thunderstorm'
  };
  
  const condition = conditions[weather.weathercode] || 'Unknown';
  const text = `${location}: ${condition} ${weather.temperature}°C wind:${weather.windspeed}km/h`;
  
  return {
    source: 'open-meteo',
    location,
    text,
    timestamp: Date.now()
  };
}

// Cache management
async function getCached(location) {
  try {
    const data = await fs.readFile(CACHE_FILE, 'utf8');
    const cache = JSON.parse(data);
    const entry = cache[location];
    
    if (entry && (Date.now() - entry.timestamp) < CACHE_MAX_AGE) {
      return { ...entry, source: entry.source + ' (cached)' };
    }
  } catch (e) {
    // Cache miss or error
  }
  
  return null;
}

async function saveCache(location, data) {
  try {
    await fs.mkdir(path.dirname(CACHE_FILE), { recursive: true });
    
    let cache = {};
    try {
      const existing = await fs.readFile(CACHE_FILE, 'utf8');
      cache = JSON.parse(existing);
    } catch (e) {
      // New cache file
    }
    
    cache[location] = data;
    await fs.writeFile(CACHE_FILE, JSON.stringify(cache, null, 2));
  } catch (e) {
    console.error('Cache write failed:', e.message);
  }
}

// Main resilient weather function
async function getWeather(location) {
  const errors = [];
  
  // Try primary service
  try {
    const result = await getWeatherWttr(location);
    await saveCache(location, result);
    return result;
  } catch (e) {
    errors.push({ service: 'wttr.in', error: e.message });
  }
  
  // Try fallback service
  try {
    const result = await getWeatherOpenMeteo(location);
    await saveCache(location, result);
    return result;
  } catch (e) {
    errors.push({ service: 'open-meteo', error: e.message });
  }
  
  // Try cache
  const cached = await getCached(location);
  if (cached) {
    return cached;
  }
  
  // All failed
  throw new Error(`Weather unavailable. Errors: ${JSON.stringify(errors)}`);
}

// CLI interface
async function main() {
  const location = process.argv[2] || 'Langley BC';
  
  try {
    const weather = await getWeather(location);
    console.log(weather.text);
    if (process.env.VERBOSE) {
      console.error(`Source: ${weather.source}`);
    }
  } catch (e) {
    console.error(`Error: ${e.message}`);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { getWeather };