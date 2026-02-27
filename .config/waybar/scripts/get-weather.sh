#!/usr/bin/env bash

city="Stockbridge+GA"

# Fetch temperature and condition cleanly from wttr
temperature=$(curl -s --fail "https://wttr.in/${city}?format=%t" 2>/dev/null | sed 's/+//')
condition_text=$(curl -s --fail "https://wttr.in/${city}?format=%C" 2>/dev/null | tr '[:upper:]' '[:lower:]' | xargs)

# Fallback if curl fails
if [[ -z "$temperature" || -z "$condition_text" ]]; then
  echo '{"text":"", "alt":"Weather unavailable", "tooltip":"Failed to fetch weather"}'
  exit 0
fi

# Nerd Font icon mapping
case "$condition_text" in
  "clear" | "sunny")
    condition=""
    ;;
  "partly cloudy")
    condition=""
    ;;
  "cloudy")
    condition=""
    ;;
  "overcast")
    condition=""
    ;;
  "haze")
    condition=""
    ;;
  "fog" | "freezing fog")
    condition=""
    ;;
  "patchy rain possible" | "patchy light drizzle" | "light drizzle" | \
  "patchy light rain" | "light rain" | "light rain shower" | "mist" | "rain")
    condition=""
    ;;
  "moderate rain at times" | "moderate rain" | "heavy rain at times" | \
  "heavy rain" | "moderate or heavy rain shower" | "torrential rain shower" | "rain shower")
    condition=""
    ;;
  "patchy snow possible" | "patchy sleet possible" | "patchy freezing drizzle possible" | \
  "freezing drizzle" | "heavy freezing drizzle" | "light freezing rain" | \
  "moderate or heavy freezing rain" | "light sleet" | "ice pellets" | \
  "light sleet showers" | "moderate or heavy sleet showers")
    condition=""
    ;;
  "blowing snow" | "moderate or heavy sleet" | "patchy light snow" | \
  "light snow" | "light snow showers")
    condition=""
    ;;
  "blizzard" | "patchy moderate snow" | "moderate snow" | \
  "patchy heavy snow" | "heavy snow" | \
  "moderate or heavy snow with thunder" | "moderate or heavy snow showers")
    condition=""
    ;;
  "thundery outbreaks possible" | "patchy light rain with thunder" | \
  "moderate or heavy rain with thunder" | "patchy light snow with thunder")
    condition=""
    ;;
  *)
    condition=""   # generic weather icon instead of warning
    ;;
esac

# Output valid Waybar JSON
echo "{\"text\":\"$condition $temperature\", \"alt\":\"$condition_text\", \"tooltip\":\"${city//+/ }, $temperature — $condition_text\"}"
